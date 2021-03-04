#pragma once

#if defined(WIN32) || defined(__windows__) || defined(__WIN32__) || defined(__NT__)
   #define __windows__ true
#endif

#ifdef __windows__
#include <Windows.h>
#include <stdlib.h>
#include <wrl.h>
#include <map>
#include <string>
#include <wil/com.h>
#include <WebView2.h>
typedef const wchar_t* AutoString;
#endif

#ifdef __linux__
#include <gtk/gtk.h>
#endif

#ifdef __APPLE__
#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>
typedef char* AutoString;
#endif

#include "Structs/Monitor.h"

typedef void (*ACTION)();
typedef void (*WebMessageReceivedCallback)(AutoString message);
typedef void* (*WebResourceRequestedCallback)(AutoString url, int* outNumBytes, AutoString* outContentType);
typedef int (*GetAllMonitorsCallback)(const Monitor* monitor);
typedef void (*ResizedCallback)(int width, int height);
typedef void (*MovedCallback)(int x, int y);
typedef void (*ClosingCallback)();

class Photino
{
    private:
#ifdef __windows__
        static HINSTANCE _hInstance;
        HWND _hWnd;
        Photino* _parent;
        wil::com_ptr<ICoreWebView2Environment> _webviewEnvironment;
        wil::com_ptr<ICoreWebView2> _webviewWindow;
        wil::com_ptr<ICoreWebView2Controller> _webviewController;
        std::map<std::wstring, WebResourceRequestedCallback> _schemeToRequestHandler;

        void AttachWebView();
#elif __linux__
        GtkWidget* _window;
        GtkWidget* _webview;
#elif __APPLE__
        NSWindow* _window;
        WKWebView* _webView;
        WKWebViewConfiguration* _webViewConfiguration;

        void AttachWebView();
#endif

        WebMessageReceivedCallback _webMessageReceivedCallback;
        MovedCallback _movedCallback;
        ResizedCallback _resizedCallback;
        ClosingCallback _closingCallback;

    public:
#ifdef __windows__
        static void Register(HINSTANCE hInstance);
        HWND getHwnd();
        void RefitContent();
#elif __APPLE__
        static void Register();
#endif

        Photino(
            AutoString title,
            Photino* parent,
            WebMessageReceivedCallback webMessageReceivedCallback,
            bool fullscreen,
            int x,
            int y,
            int width,
            int height);

        ~Photino();

        /**
         * Class Methods
         */
        // void Open();
        void Close();

        void Show();
        // void Hide();

        void WaitForExit(); // Run()

        void AddCustomScheme(AutoString scheme, WebResourceRequestedCallback requestHandler);
        
        void NavigateToUrl(AutoString url);
        void NavigateToString(AutoString content);

        void ShowMessage(AutoString title, AutoString body, unsigned int type);
        
        void SendWebMessage(AutoString message);
        
        void GetAllMonitors(GetAllMonitorsCallback callback);
        unsigned int GetScreenDpi();

        /**
         * Event Handling
         */
        void Invoke(ACTION callback);
        void InvokeResized(int width, int height) { if (_resizedCallback) _resizedCallback(width, height); }
        void InvokeMoved(int x, int y) { if (_movedCallback) _movedCallback(x, y); }
        void InvokeClosing() { if (_closingCallback) _closingCallback(); }

        void SetResizedCallback(ResizedCallback callback) { _resizedCallback = callback; }
        void SetMovedCallback(MovedCallback callback) { _movedCallback = callback; }
        void SetClosingCallback(ClosingCallback callback) { _closingCallback = callback; }
        
        /**
         * Getters & Setters
         */
        void SetTitle(AutoString title);

        void SetResizable(bool resizable);
        void GetSize(int* width, int* height);
        void SetSize(int width, int height);

        void GetPosition(int* x, int* y);
        void SetPosition(int x, int y);

        void SetTopmost(bool topmost);
        
        void SetIconFile(AutoString filename);
};
