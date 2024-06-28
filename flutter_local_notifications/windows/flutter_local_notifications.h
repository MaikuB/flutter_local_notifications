#ifndef FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_H
#define FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_H

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.UI.Notifications.h>

#include "methods.h"

namespace local_notifications {

using FlutterMap = flutter::EncodableMap;
using FlutterList = flutter::EncodableList;
using FlutterMethodCall = flutter::MethodCall<flutter::EncodableValue>;
using FlutterMethodResult = flutter::MethodResult<flutter::EncodableValue>;

class FlutterLocalNotifications : public flutter::Plugin {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);
    FlutterLocalNotifications(std::shared_ptr<PluginMethodChannel> channel);
    virtual ~FlutterLocalNotifications();
    FlutterLocalNotifications(const FlutterLocalNotifications&) = delete;
    FlutterLocalNotifications& operator=(const FlutterLocalNotifications) = delete;

  private:
    winrt::hstring _aumid;
    std::optional<winrt::Windows::UI::Notifications::ToastNotifier> toastNotifier;
    std::optional<winrt::Windows::UI::Notifications::ToastNotificationHistory> toastHistory;
    std::shared_ptr<PluginMethodChannel> channel;
    bool hasIdentity = false;

    std::optional<bool> HasIdentity();

    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
      const FlutterMethodCall& methodCall,
      std::unique_ptr<FlutterMethodResult> result
    );

    bool Initialize(
      const std::string& appName,
      const std::string& aumid,
      const std::string& guid,
      const std::optional<std::string>& iconPath,
      const std::optional<std::string>& iconColor
    );

    bool ShowNotification(const int id, const std::string& xml, const FlutterMap& args);

    bool ScheduleNotification(const int id, const std::string xml, const int time);

    void CancelAll();

    void CancelNotification(const int id);

    void GetActiveNotifications(FlutterList& result);

    void GetPendingNotifications(FlutterList& result);

    int Update(const int id, const FlutterMap& map);
};

}

#endif
