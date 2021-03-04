#pragma once
#include "../Shared/Photino.h"

typedef void (*WebMessageReceivedCallback) (char* message);

@interface PhotinoUiDelegate : NSObject <WKUIDelegate, WKScriptMessageHandler> {
    @public
    NSWindow * window;
    Photino * photino;
    WebMessageReceivedCallback webMessageReceivedCallback;
}
@end
