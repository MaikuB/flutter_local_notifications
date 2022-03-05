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

#endif  // FLUTTER_PLUGIN_FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN_H_
