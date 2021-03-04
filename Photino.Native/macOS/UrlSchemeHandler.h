#pragma once
#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>

typedef void* (*WebResourceRequestedCallback) (char* url, int* outNumBytes, char** outContentType);

@interface PhotinoUrlSchemeHandler : NSObject <WKURLSchemeHandler> {
    @public
    WebResourceRequestedCallback requestHandler;
}
@end
