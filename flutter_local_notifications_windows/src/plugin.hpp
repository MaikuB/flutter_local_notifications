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
    /// Whether the plugin has been properly initialized.
    bool isReady = false;

    /// Whether the current application has package identity (ie, was packaged with an MSIX).
    ///
    /// This impacts whether apps can query active notifications or cancel them.
    /// For more details, see https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/package-identity-overview.
    bool hasIdentity = false;

    /// The app user model ID. Used instead of package identity when [hasIdentity] is false.
    ///
    /// For more details, see https://learn.microsoft.com/en-us/windows/win32/shell/appids
    winrt::hstring aumid;

    /// The API responsible for showing notifications. Null if [isReady] is false.
    optional<ToastNotifier> notifier;

    /// The API responsible for querying shown notifications. Null if [isReady] is false.
    optional<ToastNotificationHistory> history;

    /// A callback to run when a notification is pressed, when the app is or is not running.
    NativeNotificationCallback callback;

    WinRTPlugin() { }
    ~WinRTPlugin() { }

    /// Checks whether the current application has package identity. See [hasIdentity] for details.
    ///
    /// Returns true or false if the package has identity, or null if an error occurred.
    std::optional<bool> checkIdentity();

    /// Registers the given [callback] to run when a notification is pressed.
    bool registerApp(
      const string& aumid,
      const string& appName,
      const string& guid,
      const optional<string>& iconPath,
      NativeNotificationCallback callback
    );
};
