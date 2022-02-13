// Huge credit to these StackOverflow answers:
// https://stackoverflow.com/questions/51947833/activation-from-c-winrt-dll
// https://stackoverflow.com/questions/67005337/how-works-notifications-on-windows-registry-no-shortlink

#include "registration.h"

#include <shlobj.h>
#include <propvarutil.h>
#include <propkey.h>
#include <atlbase.h>
#include <atlconv.h>
#include <NotificationActivationCallback.h>
#include <notificationactivationcallback.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include <iostream>
#include <sstream>

/// <summary>
/// The GUID that identifies the notification activation callback.
/// 68d0c89d-760f-4f79-a067-ae8d4220ccc1
/// </summary>
static constexpr winrt::guid CALLBACK_GUID{
	0x68d0c89d, 0x760f, 0x4f79, {0xa0, 0x67, 0xae, 0x8d, 0x42, 0x20, 0xcc, 0xc1}
};

const std::string CALLBACK_GUID_STR = "{68d0c89d-760f-4f79-a067-ae8d4220ccc1}";

/// <summary>
/// This callback will be called when a notification sent by this plugin is clicked on.
/// </summary>
struct NotificationActivationCallback : winrt::implements<NotificationActivationCallback, INotificationActivationCallback>
{
	HRESULT __stdcall Activate(
		LPCWSTR app,
		LPCWSTR args,
		[[maybe_unused]] NOTIFICATION_USER_INPUT_DATA const* data,
		[[maybe_unused]] ULONG count) noexcept final
	{
		try {
			std::wcout << L"Example" << L" has been called back from a notification." << std::endl;
			std::wcout << L"Value of the 'app' parameter is '" << app << L"'." << std::endl;
			std::wcout << L"Value of the 'args' parameter is '" << args << L"'." << std::endl;
			return S_OK;
		}
		catch (...) {
			return winrt::to_hresult();
		}
	}
};

/// <summary>
/// A class factory that creates an instance of NotificationActivationCallback.
/// </summary>
struct NotificationActivationCallbackFactory : winrt::implements<NotificationActivationCallbackFactory, IClassFactory>
{
	HRESULT __stdcall CreateInstance(
		IUnknown* outer,
		GUID const& iid,
		void** result) noexcept final
	{
		*result = nullptr;

		if (outer) {
			return CLASS_E_NOAGGREGATION;
		}

		return winrt::make<NotificationActivationCallback>()->QueryInterface(iid, result);
	}

	HRESULT __stdcall LockServer(BOOL) noexcept final {
		return S_OK;
	}
};

struct RegistryHandle
{
	using type = HKEY;

	static void close(type value) noexcept {
		WINRT_VERIFY_(ERROR_SUCCESS, RegCloseKey(value));
	}

	static constexpr type invalid() noexcept {
		return nullptr;
	}
};

/// <summary>
/// A handle to a registry key.
/// </summary>
using RegistryKey = winrt::handle_type<RegistryHandle>;

/// <summary>
/// Updates the Registry to enable notifications.
/// </summary>
/// <param name="aumid">The app user model ID of the app. Provided during initialization of the plugin.</param>
/// <param name="appName">The display name of the app. The name will be shown on the notification toasts.</param>
/// <param name="iconPath">An optional path to the icon of the app. The icon will be shown on the notification toasts</param>
/// <param name="iconBgColor">An optional string that specifies the background color of the icon, in the format of AARRGGBB.</param>
void UpdateRegistry(
	const std::string& aumid,
	const std::string& appName,
	const std::optional<std::string>& iconPath,
	const std::optional<std::string>& iconBgColor
) {
	std::cout << "Update registry" << std::endl;

	std::stringstream ss;
	ss << "Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications\\Backup\\" << aumid;
	const auto key_path = ss.str();
	RegistryKey key;

	// create registry key
	winrt::check_win32(RegCreateKeyExA(
		HKEY_CURRENT_USER,
		key_path.c_str(),
		0,
		nullptr,
		0,
		KEY_WRITE,
		nullptr,
		key.put(),
		nullptr));

	// put the following key values under the key
	// appType = app:desktop
	// Setting = s:banner,s:toast,s:audio,c:toast,c:ringing
	// wnsId = NonImmersivePackage
	const std::string appType = "app:desktop";
	const std::string setting = "s:banner,s:toast,s:audio,c:toast,c:ringing";
	const std::string wnsId = "NonImmersivePackage";
	winrt::check_win32(RegSetValueExA(
		key.get(),
		"appType",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(appType.c_str()),
		static_cast<uint32_t>(appType.size() + 1 * sizeof(char))));

	winrt::check_win32(RegSetValueExA(
		key.get(),
		"Setting",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(setting.c_str()),
		static_cast<uint32_t>(setting.size() + 1 * sizeof(char))));

	winrt::check_win32(RegSetValueExA(
		key.get(),
		"wnsId",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(wnsId.c_str()),
		static_cast<uint32_t>(wnsId.size() + 1 * sizeof(char))));

	ss.clear();
	ss.str(std::string());
	ss << "Software\\Classes\\AppUserModelId\\" << aumid;
	const auto appInfoKeyPath = ss.str();
	std::cout << "aumid " << appInfoKeyPath << std::endl;
	RegistryKey appInfoKey;

	// create registry key
	winrt::check_win32(RegCreateKeyExA(
		HKEY_CURRENT_USER,
		appInfoKeyPath.c_str(),
		0,
		nullptr,
		0,
		KEY_WRITE,
		nullptr,
		appInfoKey.put(),
		nullptr));

	winrt::check_win32(RegSetValueExA(
		appInfoKey.get(),
		"DisplayName",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(appName.c_str()),
		static_cast<uint32_t>(appName.size() + 1 * sizeof(char))));

	if (iconPath.has_value()) {
		const auto v = iconPath.value();
		winrt::check_win32(RegSetValueExA(
			appInfoKey.get(),
			"IconUri",
			0,
			REG_SZ,
			reinterpret_cast<const BYTE*>(v.c_str()),
			static_cast<uint32_t>(v.size() + 1 * sizeof(char))));
	}

	if (iconBgColor.has_value()) {
		const auto v = iconBgColor.value();
		winrt::check_win32(RegSetValueExA(
			appInfoKey.get(),
			"IconBackgroundColor",
			0,
			REG_SZ,
			reinterpret_cast<const BYTE*>(v.c_str()),
			static_cast<uint32_t>(v.size() + 1 * sizeof(char))));
	}

	winrt::check_win32(RegSetValueExA(
		appInfoKey.get(),
		"CustomActivator",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(CALLBACK_GUID_STR.c_str()),
		static_cast<uint32_t>(CALLBACK_GUID_STR.size() + 1 * sizeof(char))));
}

void RegisterCallback() {
	DWORD registration{};

	winrt::check_hresult(CoRegisterClassObject(
		CALLBACK_GUID,
		winrt::make<NotificationActivationCallbackFactory>().get(),
		CLSCTX_LOCAL_SERVER,
		REGCLS_SINGLEUSE,
		&registration));
}

void PluginRegistration::RegisterApp(
	const std::string& aumid,
	const std::string& appName,
	const std::optional<std::string>& iconPath,
	const std::optional<std::string>& iconBgColor
) {
	std::cout << "register app" << std::endl;
	UpdateRegistry(aumid, appName, iconPath, iconBgColor);
	RegisterCallback();
}
