#pragma once

#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.UI.Notifications.h>

#include "ffi_api.h"
#include "utils.hpp"
#include "registration.hpp"

namespace notifications {

using std::optional;
using std::vector;
using namespace winrt::Windows::UI::Notifications;

class NativePlugin {
  private:
    bool hasIdentity = false;
    winrt::hstring aumid;
    optional<ToastNotifier> notifier;
    optional<ToastNotificationHistory> history;
    NativeNotificationCallback callback;

    /// Checks if this app was installed using an MSIX packager.
    ///
    /// See: https://learn.microsoft.com/en-us/windows/msix/detect-package-identity.
    optional<bool> checkIdentity();

  public:
    NativePlugin();
    ~NativePlugin();

    LaunchData launchData { };
    void handleLaunchData(LaunchData);

    bool init(string appName, string aumid, string guid, optional<string> iconPath, NativeNotificationCallback callback);
    bool showNotification(int id, string xml, Bindings bindings);
    bool scheduleNotification(int id, string xml, time_t time);
    NativeUpdateResult updateNotification(int id, Bindings bindings);
    void cancelAll();
    void cancelNotification(int id);
    vector<NativeDetails> getActiveNotifications();
    vector<NativeDetails> getPendingNotifications();
};

}
