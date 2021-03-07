#pragma once
#include <Cocoa/Cocoa.h>

#include "../Shared/Photino.h"

@interface PhotinoWindowDelegate : NSObject <NSWindowDelegate>
{
    @public
        NSWindow* nativeWindow;
        Photino* photinoWindow;
}
@end
