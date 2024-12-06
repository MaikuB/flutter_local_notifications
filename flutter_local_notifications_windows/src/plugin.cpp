#include <sstream>

#include <windows.h>  // <-- This must be the first Windows header
#include <appmodel.h>
#include <atlbase.h>
#include <NotificationActivationCallback.h>
#include <VersionHelpers.h>

#include "plugin.hpp"
#include "utils.hpp"

struct RegistryHandle {
  using type = HKEY;

  static void close(type value) noexcept { WINRT_VERIFY_(ERROR_SUCCESS, RegCloseKey(value)); }

  static constexpr type invalid() noexcept { return nullptr; }
};

using RegistryKey = winrt::handle_type<RegistryHandle>;

/// This callback will be called when a notification sent by this plugin is clicked on.
struct NotificationActivationCallback :
    winrt::implements<NotificationActivationCallback, INotificationActivationCallback> {
  NativeNotificationCallback callback;

  HRESULT __stdcall Activate(
    LPCWSTR app, LPCWSTR args, NOTIFICATION_USER_INPUT_DATA const* data, ULONG count
  ) noexcept final {
    try {
      // Fill the data map
      vector<StringMapEntry> entries;
      for (ULONG i = 0; i < count; i++) {
        auto item = data[i];
        const std::string key = CW2A(item.Key);
        const std::string value = CW2A(item.Value);
        const auto pair = StringMapEntry {toNativeString(key), toNativeString(value)};
        entries.push_back(pair);
      }

      const auto openedWithAction = args != nullptr;
      const auto payload = string(CW2A(args));
      const auto launchType =
        openedWithAction ? NativeLaunchType::action : NativeLaunchType::notification;
      NativeLaunchDetails launchDetails;
      launchDetails.didLaunch = true;
      launchDetails.launchType = launchType;
      launchDetails.payload = toNativeString(payload);
      launchDetails.data = toNativeMap(entries);
      callback(launchDetails);
      return S_OK;
    } catch (...) {
      return winrt::to_hresult();
    }
  }
};

/// A class factory that creates an instance of NotificationActivationCallback.
struct NotificationActivationCallbackFactory :
    winrt::implements<NotificationActivationCallbackFactory, IClassFactory> {
  NativeNotificationCallback callback;

  HRESULT __stdcall CreateInstance(IUnknown* outer, GUID const& iid, void** result) noexcept final {
    *result = nullptr;
    if (outer) return CLASS_E_NOAGGREGATION;
    const auto cb = winrt::make_self<NotificationActivationCallback>();
    cb.get()->callback = callback;
    return cb->QueryInterface(iid, result);
  }

  HRESULT __stdcall LockServer(BOOL) noexcept final { return S_OK; }
};

/// Updates the Registry to enable notifications.
///
/// Related resources:
/// https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/send-local-toast-other-apps
void UpdateRegistry(
  const std::string& aumid, const std::string& appName, const std::string& guid,
  const std::optional<std::string>& iconPath
) {
  std::stringstream ss;
  ss << "Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications\\Backup\\" << aumid;
  const auto notifSettingsKeyPath = ss.str();
  RegistryKey key;

  // create registry key
  // HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup
  winrt::check_win32(RegCreateKeyExA(
    HKEY_CURRENT_USER, notifSettingsKeyPath.c_str(), 0, nullptr, 0, KEY_WRITE, nullptr, key.put(),
    nullptr
  ));

  // put the following key values under the key
  // HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\<aumid>
  //
  // appType = app:desktop
  // Setting = s:banner,s:toast,s:audio,c:toast,c:ringing
  // wnsId = NonImmersivePackage

  const std::string appType = "app:desktop";
  const std::string setting = "s:banner,s:toast,s:audio,c:toast,c:ringing";
  const std::string wnsId = "NonImmersivePackage";
  winrt::check_win32(RegSetValueExA(
    key.get(), "appType", 0, REG_SZ, reinterpret_cast<const BYTE*>(appType.c_str()),
    static_cast<uint32_t>(appType.size() + 1 * sizeof(char))
  ));
  winrt::check_win32(RegSetValueExA(
    key.get(), "Setting", 0, REG_SZ, reinterpret_cast<const BYTE*>(setting.c_str()),
    static_cast<uint32_t>(setting.size() + 1 * sizeof(char))
  ));
  winrt::check_win32(RegSetValueExA(
    key.get(), "wnsId", 0, REG_SZ, reinterpret_cast<const BYTE*>(wnsId.c_str()),
    static_cast<uint32_t>(wnsId.size() + 1 * sizeof(char))
  ));

  // now, we register app info to the Registry.

  ss.clear();
  ss.str(std::string());
  ss << "Software\\Classes\\AppUserModelId\\" << aumid;
  const auto appInfoKeyPath = ss.str();
  RegistryKey appInfoKey;

  // create registry key
  // HKEY_CURRENT_USER\Software\Classes\AppUserModelId\<aumid>
  winrt::check_win32(RegCreateKeyExA(
    HKEY_CURRENT_USER, appInfoKeyPath.c_str(), 0, nullptr, 0, KEY_WRITE, nullptr, appInfoKey.put(),
    nullptr
  ));

  winrt::check_win32(RegSetValueExA(
    appInfoKey.get(), "DisplayName", 0, REG_SZ, reinterpret_cast<const BYTE*>(appName.c_str()),
    static_cast<uint32_t>(appName.size() + 1 * sizeof(char))
  ));

  if (iconPath.has_value()) {
    const auto v = iconPath.value();
    winrt::check_win32(RegSetValueExA(
      appInfoKey.get(), "IconUri", 0, REG_SZ, reinterpret_cast<const BYTE*>(v.c_str()),
      static_cast<uint32_t>(v.size() + 1 * sizeof(char))
    ));
  }

  // combine guid to class id
  ss.clear();
  ss.str(std::string());
  ss << '{' << guid << '}';
  const auto clsid = ss.str();

  // register the guid of the notification activation callback
  winrt::check_win32(RegSetValueExA(
    appInfoKey.get(), "CustomActivator", 0, REG_SZ, reinterpret_cast<const BYTE*>(clsid.c_str()),
    static_cast<uint32_t>(clsid.size() + 1 * sizeof(char))
  ));
}

/// Register the notification activation callback factory
/// and the guid of the callback.
bool RegisterCallback(const std::string& guid, NativeNotificationCallback callback) {
  DWORD registration {};
  winrt::guid rclsid = parseGuid(guid);
  const auto factory_ref = winrt::make_self<NotificationActivationCallbackFactory>();
  const auto factory = factory_ref.get();
  factory->callback = callback;
  winrt::check_hresult(
    CoRegisterClassObject(rclsid, factory, CLSCTX_LOCAL_SERVER, REGCLS_MULTIPLEUSE, &registration)
  );
  return true;
}

bool NativePlugin::registerApp(
  const string& aumid, const string& appName, const string& guid, const optional<string>& iconPath,
  NativeNotificationCallback callback
) {
  UpdateRegistry(aumid, appName, guid, iconPath);
  return RegisterCallback(guid, callback);
}

std::optional<bool> NativePlugin::checkIdentity() {
  if (!IsWindows8OrGreater()) return false;
  uint32_t length = 0;
  auto error = GetCurrentPackageFullName(&length, nullptr);
  if (error == APPMODEL_ERROR_NO_PACKAGE) {
    return false;
  } else if (error != ERROR_INSUFFICIENT_BUFFER) {
    return std::nullopt;
  }
  std::vector<wchar_t> fullName;
  error = GetCurrentPackageFullName(&length, fullName.data());
  if (error != ERROR_SUCCESS) return std::nullopt;
  return true;
}
