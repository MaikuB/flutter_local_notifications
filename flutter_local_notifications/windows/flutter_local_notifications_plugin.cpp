#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"
#include "include/flutter_local_notifications/methods.h"
#include "utils/utils.h"
#include "registration.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <ShObjIdl_core.h>
#include <VersionHelpers.h>
#include <appmodel.h>
#include <NotificationActivationCallback.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.UI.Notifications.Preview.h>
#include <winrt/Windows.UI.Notifications.Management.h>
#include <winrt/Windows.Data.Xml.Dom.h>
#include <winrt/Windows.ApplicationModel.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/base.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

using namespace winrt::Windows::Data::Xml::Dom;
namespace {

	class FlutterLocalNotificationsPlugin : public flutter::Plugin {
	public:
		static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

		FlutterLocalNotificationsPlugin(std::shared_ptr<PluginMethodChannel> channel);

		virtual ~FlutterLocalNotificationsPlugin();

	private:
		std::wstring _aumid;
		std::optional<winrt::Windows::UI::Notifications::ToastNotifier> toastNotifier;
		std::optional<winrt::Windows::UI::Notifications::ToastNotificationHistory> toastNotificationHistory;
		std::shared_ptr<PluginMethodChannel> channel;

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
		/// <returns>Whether the initialization was successful.</returns>
		bool Initialize(
			const std::string& appName,
			const std::string& aumid,
			const std::string& guid,
			const std::optional<std::string>& iconPath,
			const std::optional<std::string>& iconBgColor);

		/// <summary>
		/// Displays a single notification toast.
		/// </summary>
		/// <param name="id">A unique ID that identifies this notification. It can be used to cancel/dismiss the notification.</param>
		void ShowNotification(
			const int id,
			const std::optional<std::string>& group,
			const std::optional<flutter::EncodableMap>& platformSpecifics);

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

		/// <summary>
		/// Gets all active notifications. Requires an MSIX package to use.
		/// </summary
		void GetActiveNotifications(std::vector<flutter::EncodableValue>& result);

		/// <summary>
		/// Gets all pending or scheduled notifications.
		/// </summary
		void GetPendingNotifications(std::vector<flutter::EncodableValue>& result);

		std::optional<bool> HasIdentity();

		/// <summary>
		/// Schedules a notification to be shown later.
		/// </summary>
		/// <param name="id">A unique ID that identifies this notification. It can be used to cancel/dismiss the notification.</param>
		void ScheduleNotification(
			const int id,
			const flutter::EncodableMap& platformSpecifics);

		/// <summary>
		/// Updates a progress bar with the given id.
		/// </summary>
		/// <param name="id">A unique ID that identifies this progress bar.</param>
		/// <param name="value">A float (0.0 - 1.0) that determines the progress</param>
		/// <param name="label">A label to display instead of the percentage</param>
		void UpdateProgress(const int id,
			const std::optional<float> value,
			const std::optional<std::string> label);
	};

	// static
	void FlutterLocalNotificationsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar) {
		auto channel =
			std::make_shared<PluginMethodChannel>(
				registrar->messenger(), "dexterous.com/flutter/local_notifications",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<FlutterLocalNotificationsPlugin>(channel);

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
			plugin_pointer->HandleMethodCall(call, std::move(result));
		});

		registrar->AddPlugin(std::move(plugin));
	}

	FlutterLocalNotificationsPlugin::FlutterLocalNotificationsPlugin(std::shared_ptr<PluginMethodChannel> channel) :
		channel(channel) {}

	FlutterLocalNotificationsPlugin::~FlutterLocalNotificationsPlugin() {}

	void FlutterLocalNotificationsPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result
	) {
		const auto& method_name = method_call.method_name();
		if (method_name == Method::GET_NOTIFICATION_APP_LAUNCH_DETAILS) {
			result->Success();
		}
		else if (method_name == Method::INITIALIZE) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr) {
				try {
					const auto appName = Utils::GetMapValue<std::string>("appName", args).value();
					const auto aumid = Utils::GetMapValue<std::string>("aumid", args).value();
					const auto guid = Utils::GetMapValue<std::string>("guid", args).value();
					const auto iconPath = Utils::GetMapValue<std::string>("iconPath", args);
					const auto iconBgColor = Utils::GetMapValue<std::string>("iconBgColor", args);

					result->Success(Initialize(appName, aumid, guid, iconPath, iconBgColor));
				}
				// handle exception when user provide a invalid guid.
				catch (std::invalid_argument err) {
					result->Error("INVALID_ARGUMENT", err.what());
				}
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::SHOW) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr && toastNotifier.has_value()) {
				try {
					const auto id = Utils::GetMapValue<int>("id", args).value();
					const auto group = Utils::GetMapValue<std::string>("group", args);
					const auto platformSpecifics = Utils::GetMapValue<flutter::EncodableMap>("platformSpecifics", args);

					ShowNotification(id, group, platformSpecifics);
					result->Success();
				} catch (winrt::hresult_error error) {
					result->Error("Invalid XML", "The XML was invalid. If you used raw XML, please verify it. If not, please report this error");
				} catch (...) {
					result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
				}
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::CANCEL && toastNotifier.has_value()) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr) {
				const auto id = Utils::GetMapValue<int>("id", args).value();
				const auto group = Utils::GetMapValue<std::string>("group", args);

				CancelNotification(id, group);
				result->Success();
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::CANCEL_ALL && toastNotifier.has_value()) {
			CancelAllNotifications();
			result->Success();
		}
		else if (method_name == Method::GET_ACTIVE_NOTIFICATIONS && toastNotifier.has_value()) {
			try {
				std::vector<flutter::EncodableValue> vec;
				GetActiveNotifications(vec);
				result->Success(flutter::EncodableValue(vec));
			} catch (std::exception error) {
				result->Error("INTERNAL", error.what());
			} catch (winrt::hresult_error error) {
				// Windows apps need to be in an MSIX to use this API.
				// Return an empty list if that's the case
				std::vector<flutter::EncodableValue> vec;
				result->Success(vec);
			} catch (...) {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::GET_PENDING_NOTIFICATIONS && toastNotifier.has_value()) {
			try {
				std::vector<flutter::EncodableValue> vec;
				GetPendingNotifications(vec);
				result->Success(vec);
			} catch (std::exception error) {
				result->Error("INTERNAL", error.what());
			} catch (...) {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::SCHEDULE_NOTIFICATION && toastNotifier.has_value()) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			const auto id = Utils::GetMapValue<int>("id", args).value();
			const auto platformSpecifics = Utils::GetMapValue<flutter::EncodableMap>("platformSpecifics", args);
			try {
				ScheduleNotification(id, platformSpecifics.value());
				result->Success();
			} catch (...) {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else {
			result->NotImplemented();
		}
	}

	std::optional<bool> FlutterLocalNotificationsPlugin::HasIdentity() {
		if (!IsWindows8OrGreater()) {
			// OS is windows 7 or lower
			return false;
		}

		UINT32 length = 0;
		auto err = GetCurrentPackageFullName(&length, NULL);
		if (err != ERROR_INSUFFICIENT_BUFFER) {
			if (err == APPMODEL_ERROR_NO_PACKAGE)
				return false;

			return std::nullopt;
		}

		PWSTR fullName = (PWSTR)malloc(length * sizeof(*fullName));
		if (fullName == nullptr)
			return std::nullopt;

		err = GetCurrentPackageFullName(&length, fullName);
		if (err != ERROR_SUCCESS)
			return std::nullopt;

		free(fullName);

		return true;
	}

	bool FlutterLocalNotificationsPlugin::Initialize(
		const std::string& appName,
		const std::string& aumid,
		const std::string& guid,
		const std::optional<std::string>& iconPath,
		const std::optional<std::string>& iconBgColor
	) {
		_aumid = winrt::to_hstring(aumid);
		auto didRegister = PluginRegistration::RegisterApp(aumid, appName, guid, iconPath, iconBgColor, channel);
		if (!didRegister) return false;

		const auto hasIdentity = HasIdentity();
		if (!hasIdentity.has_value())
			return false;

		if (hasIdentity.value())
			toastNotifier = winrt::Windows::UI::Notifications::ToastNotificationManager::CreateToastNotifier();
		else
			toastNotifier = winrt::Windows::UI::Notifications::ToastNotificationManager::CreateToastNotifier(winrt::to_hstring(aumid));

		return true;
	}

	void FlutterLocalNotificationsPlugin::ShowNotification(
		const int id,
		const std::optional<std::string>& group,
		const std::optional<flutter::EncodableMap>& platformSpecifics
	) {
		auto rawXml = Utils::GetMapValue<std::string>("rawXml", &platformSpecifics.value());
		XmlDocument doc;
		doc.LoadXml(winrt::to_hstring(rawXml.value()));

		winrt::Windows::UI::Notifications::ToastNotification notif{ doc };
		notif.Tag(winrt::to_hstring(id));
		if (group.has_value()) {
			notif.Group(winrt::to_hstring(*group));
		}
		else {
			notif.Group(_aumid);
		}
		toastNotifier.value().Show(notif);
	}

	void FlutterLocalNotificationsPlugin::CancelNotification(const int id, const std::optional<std::string>& group) {
		if (!toastNotificationHistory.has_value()) {
			toastNotificationHistory = winrt::Windows::UI::Notifications::ToastNotificationManager::History();
		}

		if (group.has_value()) {
			toastNotificationHistory.value().Remove(winrt::to_hstring(id), winrt::to_hstring(group.value()), _aumid);
		}
		else {
			toastNotificationHistory.value().Remove(winrt::to_hstring(id), _aumid, _aumid);
		}
	}

	void FlutterLocalNotificationsPlugin::CancelAllNotifications() {
		if (!toastNotificationHistory.has_value()) {
			toastNotificationHistory = winrt::Windows::UI::Notifications::ToastNotificationManager::History();
		}
		toastNotificationHistory.value().Clear(_aumid);
	}

	void FlutterLocalNotificationsPlugin::GetActiveNotifications(std::vector<flutter::EncodableValue>& result) {
		if (!toastNotificationHistory.has_value()) {
			toastNotificationHistory = winrt::Windows::UI::Notifications::ToastNotificationManager::History();
		}
		const auto history = toastNotificationHistory.value().GetHistory();
		const uint32_t size = history.Size();
		for (uint32_t i = 0; i < size; i++) {
			flutter::EncodableMap data;
			const auto notif = history.GetAt(i);
			const auto tag = notif.Tag();
			const auto tagString = winrt::to_string(tag);
			const auto tagInt = std::stoi(tagString);
			data[std::string("id")] = flutter::EncodableValue(tagInt);
			result.emplace_back(flutter::EncodableValue(data));
		}
	}

	void FlutterLocalNotificationsPlugin::GetPendingNotifications(std::vector<flutter::EncodableValue>& result) {
		const auto scheduled = toastNotifier.value().GetScheduledToastNotifications();
		for (const auto notif : scheduled) {
			flutter::EncodableMap data;
			const auto tag = notif.Tag();
			const auto tagString = winrt::to_string(tag);
			const auto tagInt = std::stoi(tagString);
			data[std::string("id")] = flutter::EncodableValue(tagInt);
			result.emplace_back(flutter::EncodableValue(data));
		}
	}

	void FlutterLocalNotificationsPlugin::ScheduleNotification(const int id, const flutter::EncodableMap& platformSpecifics) {
		auto rawXml = Utils::GetMapValue<std::string>("rawXml", &platformSpecifics);
		XmlDocument doc;
		doc.LoadXml(winrt::to_hstring(rawXml.value()));

		const auto secondsSinceEpoch = Utils::GetMapValue<int>("time", &platformSpecifics).value();
		time_t time(secondsSinceEpoch);
		const auto time2 = winrt::clock::from_time_t(time);
		winrt::Windows::UI::Notifications::ScheduledToastNotification notif(doc, time2);
		notif.Tag(winrt::to_hstring(id));
		toastNotifier.value().AddToSchedule(notif);
	}

	void FlutterLocalNotificationsPlugin::UpdateProgress(
		const int id,
		const std::optional<float> value,
		const std::optional<std::string> label
	) {
		
	}
}

void FlutterLocalNotificationsPluginRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	FlutterLocalNotificationsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
