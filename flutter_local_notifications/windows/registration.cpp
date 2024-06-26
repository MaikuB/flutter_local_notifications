// Huge credit to these StackOverflow answers:
// https://stackoverflow.com/questions/51947833/activation-from-c-winrt-dll
// https://stackoverflow.com/questions/67005337/how-works-notifications-on-windows-registry-no-shortlink

#include "registration.h"
#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"
#include "include/flutter_local_notifications/methods.h"

#include <atlbase.h>
#include <atlconv.h>
#include <shlobj.h>
#include <propvarutil.h>
#include <propkey.h>
#include <NotificationActivationCallback.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include <iostream>
#include <sstream>

/// <summary>
/// This callback will be called when a notification sent by this plugin is clicked on.
/// </summary>
struct NotificationActivationCallback : winrt::implements<NotificationActivationCallback, INotificationActivationCallback>
{
	std::shared_ptr<PluginMethodChannel> channel;

	HRESULT __stdcall Activate(
		LPCWSTR app,
		LPCWSTR args,
		NOTIFICATION_USER_INPUT_DATA const* data,
		ULONG count) noexcept final
	{
		try {
			std::wcout << L"Example" << L" has been called back from a notification." << std::endl;
			std::wcout << L"Value of the 'app' parameter is '" << app << L"'." << std::endl;
			std::wcout << L"Value of the 'args' parameter is '" << args << L"'." << std::endl;
			std::wcout << L"Value of the 'count' is " << count << std::endl;
			std::wcout << L"Value of the 'data' is:" << std::endl;
			flutter::EncodableMap inputData;
			for (ULONG i = 0; i < count; i++) {
				auto item = data[i];
				std::wcout << L"  Key: '" << item.Key << L"', Value: '" << item.Value << "'." << std::endl;
				inputData[std::string(CW2A(item.Key))] = std::string(CW2A(item.Value));
			}
			const std::string payload = CW2A(args);
			flutter::EncodableMap response;
			response[std::string("payload")] = flutter::EncodableValue(payload);
			response[std::string("data")] = flutter::EncodableValue(inputData);
			channel->InvokeMethod(
				Method::DID_RECEIVE_NOTIFICATION_RESPONSE,
				std::make_unique<flutter::EncodableValue>(response),
				nullptr
			);
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
	std::shared_ptr<PluginMethodChannel> channel;

	HRESULT __stdcall CreateInstance(
		IUnknown* outer,
		GUID const& iid,
		void** result) noexcept final
	{
		std::cout << "CreateInstance" << std::endl;

		*result = nullptr;

		if (outer) {
			return CLASS_E_NOAGGREGATION;
		}

		const auto cb = winrt::make_self<NotificationActivationCallback>();
		cb.get()->channel = channel;

		return cb->QueryInterface(iid, result);
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
///
/// Related resources:
/// <ul>
///   <li>https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/send-local-toast-other-apps</li>
/// </ul>
/// </summary>
/// <param name="aumid">The app user model ID of the app. Provided during initialization of the plugin.</param>
/// <param name="appName">The display name of the app. The name will be shown on the notification toasts.</param>
/// <param name="iconPath">An optional path to the icon of the app. The icon will be shown on the notification toasts</param>
/// <param name="iconBgColor">An optional string that specifies the background color of the icon, in the format of AARRGGBB.</param>
void UpdateRegistry(
	const std::string& aumid,
	const std::string& appName,
	const std::string& guid,
	const std::optional<std::string>& iconPath,
	const std::optional<std::string>& iconBgColor
) {
	std::stringstream ss;
	ss << "Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications\\Backup\\" << aumid;
	const auto notifSettingsKeyPath = ss.str();
	RegistryKey key;

	// create registry key
	// HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup
	winrt::check_win32(RegCreateKeyExA(
		HKEY_CURRENT_USER,
		notifSettingsKeyPath.c_str(),
		0,
		nullptr,
		0,
		KEY_WRITE,
		nullptr,
		key.put(),
		nullptr));

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

	// now, we register app info to the Registry.

	ss.clear();
	ss.str(std::string());
	ss << "Software\\Classes\\AppUserModelId\\" << aumid;
	const auto appInfoKeyPath = ss.str();
	RegistryKey appInfoKey;

	// create registry key
	// HKEY_CURRENT_USER\Software\Classes\AppUserModelId\<aumid>
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

	// combine guid to class id
	ss.clear();
	ss.str(std::string());
	ss << '{' << guid << '}';
	const auto clsid = ss.str();

	// register the guid of the notification activation callback
	winrt::check_win32(RegSetValueExA(
		appInfoKey.get(),
		"CustomActivator",
		0,
		REG_SZ,
		reinterpret_cast<const BYTE*>(clsid.c_str()),
		static_cast<uint32_t>(clsid.size() + 1 * sizeof(char))));
}

/// <summary>
/// Register the notificatio activation callback factory
/// and the guid of the callback.
/// </summary>
bool RegisterCallback(std::shared_ptr<PluginMethodChannel> channel, const std::string& guid) {
	DWORD registration{};

	const auto factory_ref = winrt::make_self<NotificationActivationCallbackFactory>();
	const auto factory = factory_ref.get();

	// The WinRT GUID constructor terminates the app if there's an invalid GUID, so check it here first.
	if (guid.size() != 36 || guid[8] != '-' || guid[13] != '-' || guid[18] != '-' || guid[23] != '-') {
		throw std::invalid_argument("Invalid GUID");
	}

	winrt::guid rclsid(guid);
	factory->channel = channel;

	winrt::check_hresult(CoRegisterClassObject(
		rclsid,
		factory,
		CLSCTX_LOCAL_SERVER,
		REGCLS_MULTIPLEUSE,
		&registration));
	return true;
}

bool PluginRegistration::RegisterApp(
	const std::string& aumid,
	const std::string& appName,
	const std::string& guid,
	const std::optional<std::string>& iconPath,
	const std::optional<std::string>& iconBgColor,
	std::shared_ptr<PluginMethodChannel> plugin
) {
	UpdateRegistry(aumid, appName, guid, iconPath, iconBgColor);
	return RegisterCallback(plugin, guid);
}
