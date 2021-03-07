#include <string>
#include "PhotinoWindowDelegate.h"

@implementation PhotinoWindowDelegate : NSObject
- (void)windowDidResize: (NSNotification *)notification
{
    NSRect frame = [nativeWindow frame];
    NSSize windowSize = frame.size;

    photinoWindow->InvokeResized(
        (int)roundf(windowSize.width),
        (int)roundf(windowSize.height));

    //Log::WriteLine("Window sized to: " + std::to_string(windowSize.width) + ", " + std::to_string(windowSize.height));
}

- (void)windowDidMove: (NSNotification *)notification
{
    NSRect frame = [nativeWindow frame];
    NSPoint windowLocation = frame.origin;

    photinoWindow->InvokeMoved(
        (int)roundf(windowLocation.x),
        (int)roundf(windowLocation.y));

    //Log::WriteLine("Window moved to: " + std::to_string(windowLocation.x) + ", " + std::to_string(windowLocation.y));
}

- (BOOL)windowShouldClose: (NSWindow *)sender
{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: @"Yes"];
    [alert addButtonWithTitle: @"No"];
    [alert setMessageText: @"Are you sure you want to quit?"];
    [alert setAlertStyle: NSAlertStyleWarning];
    [alert setShowsSuppressionButton:YES];

    NSInteger result = [alert runModal];

    if (result == NSAlertFirstButtonReturn) {
        photinoWindow->InvokeWindowClosing();
        return YES;
    } else {
        return NO;
    }
}

- (void)windowWillClose: (NSWindow *)sender
{
    //Log::WriteLine("Window will close");
}
@end
