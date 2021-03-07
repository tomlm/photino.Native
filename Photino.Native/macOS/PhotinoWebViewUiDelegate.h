#pragma once
#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>

typedef void (*WebMessageReceivedCallback) (char* message);

@interface PhotinoWebViewUiDelegate : NSObject <WKUIDelegate, WKScriptMessageHandler> {
    @public
        NSWindow* nativeWindow;
        WebMessageReceivedCallback webMessageReceivedCallback;
}
@end
