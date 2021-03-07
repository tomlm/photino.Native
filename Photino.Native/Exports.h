#pragma once
#include "Shared/Photino.h"

#ifdef __windows__
#define EXPORTED __declspec(dllexport)
#else
#define EXPORTED
#endif

extern "C"
{
#ifdef __windows__
	EXPORTED void Photino_register_win32(HINSTANCE hInstance);
	EXPORTED HWND Photino_getHwnd_win32(Photino* instance);
#elif __APPLE__
	EXPORTED void Photino_register_mac();
#endif
	EXPORTED Photino* Photino_ctor(AutoString title, Photino* parent, WebMessageReceivedCallback webMessageReceivedCallback, bool fullscreen, int x, int y, int width, int height);
    
    EXPORTED void Photino_dtor(Photino* instance);

    /**
     * Class Methods
     */
    EXPORTED void Photino_Show(Photino* instance);
    
    EXPORTED void Photino_Close(Photino* instance);
    
    EXPORTED void Photino_WaitForExit(Photino* instance);
    
    EXPORTED void Photino_AddCustomScheme(Photino* instance, AutoString scheme, WebResourceRequestedCallback requestHandler);
    
    EXPORTED void Photino_NavigateToUrl(Photino* instance, AutoString url);
    EXPORTED void Photino_NavigateToString(Photino* instance, AutoString content);
    
    EXPORTED void Photino_ShowMessage(Photino* instance, AutoString title, AutoString body, unsigned int type);
    
    EXPORTED void Photino_SendWebMessage(Photino* instance, AutoString message);
    
    EXPORTED void Photino_GetAllMonitors(Photino* instance, GetAllMonitorsCallback callback);
    EXPORTED unsigned int Photino_GetScreenDpi(Photino* instance);
    
    /**
     * Event Handling
     */
    EXPORTED void Photino_Invoke(Photino* instance, ACTION callback);
    
    EXPORTED void Photino_SetResizedCallback(Photino* instance, ResizedCallback callback);
    EXPORTED void Photino_SetMovedCallback(Photino* instance, MovedCallback callback);
    EXPORTED void Photino_SetWindowClosingCallback(Photino* instance, ClosingCallback callback);
    
    /**
     * Getters & Setters
     */
    EXPORTED void Photino_SetTitle(Photino* instance, AutoString title);
    
    EXPORTED void Photino_SetResizable(Photino* instance, int resizable);
    
    EXPORTED void Photino_GetSize(Photino* instance, int* width, int* height);
    EXPORTED void Photino_SetSize(Photino* instance, int width, int height);
    
    EXPORTED void Photino_GetPosition(Photino* instance, int* x, int* y);
    EXPORTED void Photino_SetPosition(Photino* instance, int x, int y);
    
    EXPORTED void Photino_SetTopmost(Photino* instance, int topmost);
    
    EXPORTED void Photino_SetIconFile(Photino* instance, AutoString filename);
}
