#include <cstdio>
#include <iostream>
#include <map>

#include "../Shared/Photino.h"

#include "AppDelegate.h"
#include "PhotinoWebViewUiDelegate.h"
#include "PhotinoWindowDelegate.h"
#include "UrlSchemeHandler.h"

using namespace std;

void Log(std::string message)
{
    std::cout << message << std::endl;
}

void Photino::Register()
{
    [NSAutoreleasePool new];

    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    id menubar = [[NSMenu new] autorelease];
    id appMenuItem = [[NSMenuItem new] autorelease];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];

    id appMenu = [[NSMenu new] autorelease];
    id appName = [[NSProcessInfo processInfo] processName];
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
        action:@selector(terminate:) keyEquivalent:@"q"] autorelease];
    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];

    PhotinoAppDelegate* appDelegate = [[[PhotinoAppDelegate alloc] init] autorelease];
    [NSApp setDelegate:appDelegate];
}

Photino::Photino(
    AutoString title,
    Photino* parent,
    WebMessageReceivedCallback webMessageReceivedCallback,
    bool fullscreen,
    int x,
    int y,
    int width,
    int height)
{

    _webMessageReceivedCallback = webMessageReceivedCallback;
    
    // Create Window
    NSRect frame = NSMakeRect(x, y, width, height);
    NSWindowStyleMask windowStyleMask = NSWindowStyleMaskTitled
            | NSWindowStyleMaskClosable
            | NSWindowStyleMaskResizable
            | NSWindowStyleMaskMiniaturizable;
    
    _window = [
        [NSWindow alloc]
        initWithContentRect: frame
        styleMask: windowStyleMask
        backing: NSBackingStoreBuffered
        defer: false
    ];

    this->SetTitle(title);

    PhotinoWindowDelegate* windowDelegate = [[
        [PhotinoWindowDelegate alloc] init
    ] autorelease];

    windowDelegate->photinoWindow = this;

    _window.delegate = windowDelegate;

    this->AttachWebView();
}

Photino::~Photino()
{
    [_webViewConfiguration release];
    [_webView release];
    [_window release];
}

void Photino::AttachWebView()
{
    // Javascript Extension Methods
    std::string photinoWebViewExtensions = R"js(
window.__receiveMessageCallbacks = [];

window.__dispatchMessageCallback = function(message)
{
    window.__receiveMessageCallbacks
        .forEach(function(callback) 
        {
            callback(message);
        });
};

window.external = {
    sendMessage: function(message)
    {
        window.webkit
            .messageHandlers
            .photinointerop
            .postMessage(message);
    },
    receiveMessage: function(callback)
    {
        window.__receiveMessageCallbacks.push(callback);
    }
};
)js";

    NSString* userScriptSource = [
        NSString
        stringWithUTF8String: photinoWebViewExtensions.c_str()
    ];

    WKUserScript* userScript = [[
        [WKUserScript alloc]
        initWithSource: userScriptSource
        injectionTime: WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly: YES
    ] autorelease];
    
    // WebView Configuration
    _webViewConfiguration = [
        [[WKWebViewConfiguration alloc] init
    ] autorelease];
    
    [
        _webViewConfiguration.preferences
        setValue: @YES
        forKey: @"developerExtrasEnabled"
    ];

    _webViewConfiguration.userContentController = [[
        [WKUserContentController alloc] init
    ] autorelease];

    [_webViewConfiguration.userContentController addUserScript: userScript];

    _webView = [
        [WKWebView alloc]
        initWithFrame: _window.contentView.frame
        configuration: _webViewConfiguration
    ];
    
    [_webView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

    [_window.contentView addSubview: _webView];
    [_window.contentView setAutoresizesSubviews: YES];

    // Ui Delegation
    PhotinoWebViewUiDelegate* uiDelegate = [[
        [PhotinoWebViewUiDelegate alloc] init
    ] autorelease];
    
    uiDelegate->nativeWindow = _window;
    uiDelegate->webMessageReceivedCallback = _webMessageReceivedCallback;

    _webView.UIDelegate = uiDelegate;

    [
        _webViewConfiguration.userContentController
        addScriptMessageHandler: uiDelegate
        name: @"photinointerop"
    ];
}

void Photino::Show()
{
    [_window orderFrontRegardless];
}

void Photino::Close()
{
    [_window performClose: _window];
}

void Photino::SetTitle(AutoString title)
{
    NSString* nstitle = [[NSString stringWithUTF8String:title] autorelease];
    [_window setTitle: nstitle];
}

void Photino::WaitForExit()
{
    [NSApp run];
}

void Photino::Invoke(ACTION callback)
{
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        callback();
    });
}

void EnsureInvoke(dispatch_block_t block)
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void Photino::ShowMessage(AutoString title, AutoString body, unsigned int type)
{
    EnsureInvoke(^{
        NSString* nstitle = [[NSString stringWithUTF8String:title] autorelease];
        NSString* nsbody= [[NSString stringWithUTF8String:body] autorelease];
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [[alert window] setTitle:nstitle];
        [alert setMessageText:nsbody];
        [alert runModal];
    });
}

void Photino::NavigateToString(AutoString content)
{
    NSString* nscontent = [[NSString stringWithUTF8String:content] autorelease];
    [_webView loadHTMLString: nscontent baseURL: nil];
}

void Photino::NavigateToUrl(AutoString url)
{
    NSString* nsurlstring = [[NSString stringWithUTF8String:url] autorelease];
    NSURL *nsurl= [[NSURL URLWithString:nsurlstring] autorelease];
    NSURLRequest *nsrequest= [[NSURLRequest requestWithURL:nsurl] autorelease];
    [_webView loadRequest: nsrequest];
}

void Photino::SendWebMessage(AutoString message)
{
    // JSON-encode the message
    NSString* nsmessage = [NSString stringWithUTF8String:message];
    NSData* data = [NSJSONSerialization dataWithJSONObject:@[nsmessage] options:0 error:nil];
    NSString *nsmessageJson = [[[NSString alloc]
        initWithData:data
        encoding:NSUTF8StringEncoding] autorelease];
    nsmessageJson = [[nsmessageJson substringToIndex:([nsmessageJson length]-1)] substringFromIndex:1];

    NSString *javaScriptToEval = [NSString stringWithFormat:@"__dispatchMessageCallback(%@)", nsmessageJson];
    [_webView evaluateJavaScript:javaScriptToEval completionHandler:nil];
}

void Photino::AddCustomScheme(AutoString scheme, WebResourceRequestedCallback requestHandler)
{
    // Note that this can only be done *before* the WKWebView is instantiated, so we only let this
    // get called from the options callback in the constructor
    PhotinoUrlSchemeHandler* schemeHandler = [[[PhotinoUrlSchemeHandler alloc] init] autorelease];
    schemeHandler->requestHandler = requestHandler;

    NSString* nsscheme = [NSString stringWithUTF8String:scheme];
    [_webViewConfiguration setURLSchemeHandler:schemeHandler forURLScheme:nsscheme];
}

void Photino::SetResizable(bool resizable)
{
    if (resizable)
    {
        _window.styleMask |= NSWindowStyleMaskResizable;
    }
    else
    {
        _window.styleMask &= ~NSWindowStyleMaskResizable;
    }
}

void Photino::GetSize(int* width, int* height)
{
    NSSize size = [_window frame].size;
    if (width) *width = (int)roundf(size.width);
    if (height) *height = (int)roundf(size.height);
}

void Photino::SetSize(int width, int height)
{
    CGFloat fw = (CGFloat)width;
    CGFloat fh = (CGFloat)height;
    
    NSRect frame = [_window frame];

    CGFloat oldHeight = frame.size.height;
    CGFloat heightDelta = fh - oldHeight;  

    frame.size = CGSizeMake(fw, fh);
    frame.origin.y -= heightDelta;

    [_window setFrame: frame display: YES];
}

void Photino::GetPosition(int* x, int* y)
{
    NSRect frame = [_window frame];

    if (x) *x = (int)roundf(frame.origin.x);
    if (y) *y = (int)roundf(frame.origin.y);
}

void Photino::SetPosition(int x, int y)
{
    CGPoint position = CGPointMake((CGFloat)x, (CGFloat)y);
    [_window setFrameTopLeftPoint: position];
}

void Photino::GetAllMonitors(GetAllMonitorsCallback callback)
{
    if (callback)
    {
        for (NSScreen* screen in [NSScreen screens])
        {
            NSRect monitorFrame = [screen frame];
            MonitorRect monitorArea(
                (int)roundf(monitorFrame.origin.x),
                (int)roundf(monitorFrame.origin.y),
                (int)roundf(monitorFrame.size.width),
                (int)roundf(monitorFrame.size.height));

            NSRect workFrame = [screen visibleFrame];
            MonitorRect workArea(
                (int)roundf(workFrame.origin.x),
                (int)roundf(workFrame.origin.y),
                (int)roundf(workFrame.size.width),
                (int)roundf(workFrame.size.height));

            Monitor monitor(monitorArea, workArea);

            callback(&monitor);
        }
    }
}

unsigned int Photino::GetScreenDpi()
{
	return 72;
}

void Photino::SetTopmost(bool topmost)
{
    if (topmost) [_window setLevel:NSFloatingWindowLevel];
    else [_window setLevel:NSNormalWindowLevel];
}

void Photino::SetIconFile(AutoString filename)
{
	NSString* path = [[NSString stringWithUTF8String: filename] autorelease];
    NSImage* icon = [[[NSImage alloc] initWithContentsOfFile: path] autorelease];

    if (icon != nil)
    {
        [[_window standardWindowButton: NSWindowDocumentIconButton] setImage: icon];
    }
}
