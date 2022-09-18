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
#include <winrt/Windows.UI.Notifications.Management.h>
#include <winrt/Windows.Data.Xml.Dom.h>
#include <winrt/Windows.ApplicationModel.h>

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

		std::optional<bool> HasIdentity();
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
				const auto appName = Utils::GetMapValue<std::string>("appName", args).value();
				const auto aumid = Utils::GetMapValue<std::string>("aumid", args).value();
				const auto iconPath = Utils::GetMapValue<std::string>("iconPath", args);
				const auto iconBgColor = Utils::GetMapValue<std::string>("iconBgColor", args);

				result->Success(Initialize(appName, aumid, iconPath, iconBgColor));
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::SHOW) {
			channel->InvokeMethod("test", nullptr);

			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr && toastNotifier.has_value()) {
				const auto id = Utils::GetMapValue<int>("id", args).value();
				const auto title = Utils::GetMapValue<std::string>("title", args);
				const auto body = Utils::GetMapValue<std::string>("body", args);
				const auto payload = Utils::GetMapValue<std::string>("payload", args);
				const auto group = Utils::GetMapValue<std::string>("group", args);

				ShowNotification(id, title, body, payload, group);
				result->Success();
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
		else {
			result->NotImplemented();
		}
	}

	std::optional<bool> FlutterLocalNotificationsPlugin::HasIdentity() {
		if (!IsWindows8OrGreater()) {
			// OS is windows 7 or lower
			return false;
		}

		UINT32 length;
		auto err = GetCurrentPackageFullName(&length, NULL);
		if (err != ERROR_INSUFFICIENT_BUFFER) {
			if (err == APPMODEL_ERROR_NO_PACKAGE)
				return false;
			
			return false;
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
		const std::optional<std::string>& iconPath,
		const std::optional<std::string>& iconBgColor
	) {
		_aumid = winrt::to_hstring(aumid);
		PluginRegistration::RegisterApp(aumid, appName, iconPath, iconBgColor, channel);
		
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
		const std::optional<std::string>& title,
		const std::optional<std::string>& body,
		const std::optional<std::string>& payload,
		const std::optional<std::string>& group
	) {
		// obtain a notification template with a title and a body
		//const auto doc = winrt::Windows::UI::Notifications::ToastNotificationManager::GetTemplateContent(winrt::Windows::UI::Notifications::ToastTemplateType::ToastText02);
		// find all <text /> tags
		//const auto nodes = doc.GetElementsByTagName(L"text");

		XmlDocument doc;
		doc.LoadXml(L"\
			<toast>\
				<visual>\
					<binding template=\"ToastGeneric\">\
					</binding>\
				</visual>\
			</toast>");

		const auto bindingNode = doc.SelectSingleNode(L"//binding[1]");

		if (title.has_value()) {
			// change the text of the first <text></text>, which will be the title
			const auto textNode = doc.CreateElement(L"text");
			textNode.InnerText(winrt::to_hstring(*title));
			bindingNode.AppendChild(textNode);
		}
		if (body.has_value()) {
			// change the text of the second <text></text>, which will be the body
			//nodes.Item(1).AppendChild(doc.CreateTextNode(winrt::to_hstring(body.value())));
			const auto textNode = doc.CreateElement(L"text");
			textNode.InnerText(winrt::to_hstring(*body));
			bindingNode.AppendChild(textNode);
		}
		if (payload.has_value()) {
			std::cout << "payload: " << *payload << std::endl;
			doc.DocumentElement().SetAttribute(L"launch", winrt::to_hstring(*payload));
		}

		std::cout << winrt::to_string(doc.GetXml()) << std::endl;

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
}

void FlutterLocalNotificationsPluginRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	FlutterLocalNotificationsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
