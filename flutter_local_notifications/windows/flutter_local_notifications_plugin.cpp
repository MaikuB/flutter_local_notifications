#include <flutter/plugin_registrar_windows.h>

#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"
#include "flutter_local_notifications.h"

void FlutterLocalNotificationsPluginRegisterWithRegistrar(
  FlutterDesktopPluginRegistrar* registrar
) {
  local_notifications::FlutterLocalNotifications::RegisterWithRegistrar(
    flutter::PluginRegistrarManager::GetInstance()
      ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar)
  );
}
