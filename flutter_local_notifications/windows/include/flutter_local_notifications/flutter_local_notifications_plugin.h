#ifndef FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN_H_

#pragma once
#include <unknwn.h>
#include <winrt/Windows.Foundation.h>

#include <flutter_plugin_registrar.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.UI.Notifications.Management.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <optional>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterLocalNotificationsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

/// <summary>
/// Defines the type of the method channel used by this plugin.
/// </summary>
typedef flutter::MethodChannel<flutter::EncodableValue> PluginMethodChannel;

class FlutterLocalNotificationsPlugin : public flutter::Plugin {
public:
	static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

	PluginMethodChannel& GetPluginMethodChannel();

	FlutterLocalNotificationsPlugin(PluginMethodChannel& channel);

	virtual ~FlutterLocalNotificationsPlugin();

private:
	std::wstring _aumid;
	std::optional<winrt::Windows::UI::Notifications::ToastNotifier> toastNotifier;
	std::optional<winrt::Windows::UI::Notifications::ToastNotificationHistory> toastNotificationHistory;
	PluginMethodChannel& channel;

	// Called when a method is called on this plugin's channel from Dart.
	void HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

	/// <summary>
	/// Initializes this plugin.
	/// </summary>
	/// <param name="aumid">The app user model ID that identifies the app.</param>
	/// <param name="appName">The display name of the app.</param>
	/// <param name="iconPath">An optional path to the icon of the app.</param>
	/// <param name="iconBgColor">An optional background color of the icon, in AARRGGBB format.</param>
	void Initialize(
		const std::string& appName,
		const std::string& aumid,
		const std::optional<std::string>& iconPath,
		const std::optional<std::string>& iconBgColor);

	/// <summary>
	/// Displays a single notification toast.
	/// </summary>
	/// <param name="id">A unique ID that identifies this notification. It can be used to cancel/dismiss the notification.</param>
	/// <param name="title">An optional title of the notification.</param>
	/// <param name="body">An optional body of the notification.</param>
	/// <param name="payload"></param>
	void ShowNotification(
		const int id,
		const std::optional<std::string>& title,
		const std::optional<std::string>& body,
		const std::optional<std::string>& payload,
		const std::optional<std::string>& group);

	/// <summary>
	/// Dismisses the notification that has the given ID.
	/// </summary>
	/// <param name="id">The ID of the notification to be dismissed.</param>
	/// <param name="group">The group the notification is in. Default is the aumid of this app.</param>
	void CancelNotification(const int id, const std::optional<std::string>& group);

	/// <summary>
	/// Dismisses all currently active notifications.
	/// </summary>
	void CancelAllNotifications();
};

#endif  // FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN_H_
