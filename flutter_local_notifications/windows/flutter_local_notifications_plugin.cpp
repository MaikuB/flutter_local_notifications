#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"
#include "include/flutter_local_notifications/methods.h"
#include "utils/utils.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <ShObjIdl_core.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.UI.Notifications.Management.h>
#include <winrt/Windows.Data.Xml.Dom.h>

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

		FlutterLocalNotificationsPlugin();

		virtual ~FlutterLocalNotificationsPlugin();

	private:
		std::map<int, winrt::Windows::UI::Notifications::ToastNotification&> activeNotifications;
		std::optional<winrt::Windows::UI::Notifications::ToastNotifier> toastNotifier;

		// Called when a method is called on this plugin's channel from Dart.
		void HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void Initialize(const std::string& appName);

		void ShowNotification(
			const int id,
			const std::string& title,
			const std::string& body,
			const std::optional<std::string>& payload);

		void CancelNotification(const int id);
	};

	// static
	void FlutterLocalNotificationsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar) {
		auto channel =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
				registrar->messenger(), "dexterous.com/flutter/local_notifications",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<FlutterLocalNotificationsPlugin>();

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
			plugin_pointer->HandleMethodCall(call, std::move(result));
		});

		registrar->AddPlugin(std::move(plugin));
	}

	FlutterLocalNotificationsPlugin::FlutterLocalNotificationsPlugin() {}

	FlutterLocalNotificationsPlugin::~FlutterLocalNotificationsPlugin() {}

	void FlutterLocalNotificationsPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		std::cout << method_call.method_name() << std::endl;
		std::cout << Method::GET_NOTIFICATION_APP_LAUNCH_DETAILS << std::endl;

		const auto& method_name = method_call.method_name();
		if (method_name == Method::GET_NOTIFICATION_APP_LAUNCH_DETAILS) {
			result->Success();
		}
		else if (method_name == Method::INITIALIZE) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr) {
				const auto appName = Utils::GetMapValue<std::string>("appName", args).value();

				Initialize(appName);
				result->Success(true);
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::SHOW) {
			const auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
			if (args != nullptr && toastNotifier.has_value()) {
				const auto id = Utils::GetMapValue<int>("id", args).value();
				const auto title = Utils::GetMapValue<std::string>("title", args).value();
				const auto body = Utils::GetMapValue<std::string>("body", args).value();
				const auto payload = Utils::GetMapValue<std::string>("payload", args);

				ShowNotification(id, title, body, payload);
				result->Success();
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else if (method_name == Method::CANCEL && toastNotifier.has_value()) {
			const auto args = method_call.arguments();
			if (std::holds_alternative<int>(*args)) {
				const auto id = std::get<int>(*args);
				CancelNotification(id);
				result->Success();
			}
			else {
				result->Error("INTERNAL", "flutter_local_notifications encountered an internal error.");
			}
		}
		else {
			result->NotImplemented();
		}
	}

	void FlutterLocalNotificationsPlugin::Initialize(const std::string& appName) {
		toastNotifier = winrt::Windows::UI::Notifications::ToastNotificationManager::CreateToastNotifier(winrt::to_hstring(appName));
	}

	void FlutterLocalNotificationsPlugin::ShowNotification(
		const int id,
		const std::string& title,
		const std::string& body,
		const std::optional<std::string>& payload) {

		// obtain a notification template with a title and a body
		const auto doc = winrt::Windows::UI::Notifications::ToastNotificationManager::GetTemplateContent(winrt::Windows::UI::Notifications::ToastTemplateType::ToastText02);
		// find all <text /> tags
		const auto nodes = doc.GetElementsByTagName(L"text");
		// change the text of the first <text></text>
		nodes.Item(0).AppendChild(doc.CreateTextNode(winrt::to_hstring(title)));
		// change the text of the second <text></text>
		nodes.Item(1).AppendChild(doc.CreateTextNode(winrt::to_hstring(body)));

		winrt::Windows::UI::Notifications::ToastNotification notif{ doc };

		toastNotifier.value().Show(notif);
		activeNotifications[id] = notif;
	}

	void FlutterLocalNotificationsPlugin::CancelNotification(const int id) {
		const auto p = activeNotifications.find(id);
		if (p != activeNotifications.end()) {
			const auto& notif = p->second;
			toastNotifier.value().Hide(notif);
		}
	}
}  // namespace

void FlutterLocalNotificationsPluginRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	FlutterLocalNotificationsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
