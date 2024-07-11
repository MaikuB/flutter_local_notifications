#pragma once

#include <iostream>

#include "ffi_api.h"

#include "plugin.hpp"
#include "utils.hpp"

FFI_PLUGIN_EXPORT NativePlugin* createPlugin() {
  return reinterpret_cast<NativePlugin*>(new notifications::NativePlugin());
}

FFI_PLUGIN_EXPORT void disposePlugin(NativePlugin* plugin) {
  delete reinterpret_cast<notifications::NativePlugin*>(plugin);
}

FFI_PLUGIN_EXPORT int init(
  NativePlugin* plugin,
  char* appName,
  char* aumId,
  char* guid,
  char* iconPath,
  NativeNotificationCallback callback
) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  optional<string> icon;
  if (iconPath != nullptr) icon = string(iconPath);
  auto result = ptr->init(string(appName), string(aumId), string(guid), icon, callback);
  return result;
}

FFI_PLUGIN_EXPORT int showNotification(NativePlugin* plugin, int id, char* xml, Pair* bindings, int bindingsSize) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto bindingMap = pairsToBindings(bindings, bindingsSize);
  auto result = ptr->showNotification(id, string(xml), bindingMap);
  return result;
}

FFI_PLUGIN_EXPORT int scheduleNotification(NativePlugin* plugin, int id, char* xml, int time) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto result = ptr->scheduleNotification(id, string(xml), time);
  return result;
}

FFI_PLUGIN_EXPORT NativeUpdateResult updateNotification(NativePlugin* plugin, int id, Pair* bindings, int bindingsSize) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto bindingMap = pairsToBindings(bindings, bindingsSize);
  auto result = ptr->updateNotification(id, bindingMap);
  return result;
}

FFI_PLUGIN_EXPORT void cancelAll(NativePlugin* plugin) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  ptr->cancelAll();
}

FFI_PLUGIN_EXPORT void cancelNotification(NativePlugin* plugin, int id) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  ptr->cancelNotification(id);
}

FFI_PLUGIN_EXPORT NativeDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto vec = ptr->getActiveNotifications();
  return getDetailsArray(vec, size);
}

FFI_PLUGIN_EXPORT NativeDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto vec = ptr->getPendingNotifications();
  return getDetailsArray(vec, size);
}

FFI_PLUGIN_EXPORT NativeLaunchDetails* getLaunchDetails(NativePlugin* plugin) {
  auto ptr = reinterpret_cast<notifications::NativePlugin*>(plugin);
  auto data = ptr->launchData;
  return parseLaunchDetails(data);
}

FFI_PLUGIN_EXPORT void freeDetailsArray(NativeDetails* ptr) {
  delete[] ptr;
}

FFI_PLUGIN_EXPORT void freePairArray(Pair* ptr) {
  delete[] ptr;
}
