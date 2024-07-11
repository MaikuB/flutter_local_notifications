#pragma once

#include <string>
#include <optional>

#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.UI.Notifications.h>

#include "ffi_api.h"

using std::optional;
using std::string;
using namespace winrt::Windows::UI::Notifications;

class WinRTPlugin {
  public:
    bool hasIdentity = false;
    bool isReady = false;
    winrt::hstring aumid;
    optional<ToastNotifier> notifier;
    optional<ToastNotificationHistory> history;
    NativeLaunchDetails launchData;
    NativeNotificationCallback callback;

    WinRTPlugin() { }
    ~WinRTPlugin() { freeLaunchDetails(launchData); }

    // void onLaunch(NativeLaunchDetails details);

    std::optional<bool> checkIdentity();
    bool registerApp(
      const string& aumid,
      const string& appName,
      const string& guid,
      const optional<string>& iconPath,
      NativeNotificationCallback callback
    );
};
