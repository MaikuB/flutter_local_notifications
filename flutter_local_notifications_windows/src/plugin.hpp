#pragma once

#include <string>
#include <optional>

#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.UI.Notifications.h>

#include "ffi_api.h"

using std::optional;
using std::string;
using namespace winrt::Windows::UI::Notifications;

/// The C++ container object for WinRT handles.
///
/// Note that this must be a struct as it was forward-declared as a struct in
/// `ffi_api.h`, which cannot use classes as it must be C-compatible.
struct NativePlugin {
  /// Whether the plugin has been properly initialized.
  bool isReady = false;

  /// Whether the current application has package identity (ie, was packaged with an MSIX).
  ///
  /// See [hasPackageIdentity].
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

  NativePlugin() {}
  ~NativePlugin() {}

  /// Registers the given [callback] to run when a notification is pressed.
  bool registerApp(
    const string& aumid, const string& appName, const string& guid,
    const optional<string>& iconPath, NativeNotificationCallback callback
  );
};
