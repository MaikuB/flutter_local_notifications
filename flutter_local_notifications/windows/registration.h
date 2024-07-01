#ifndef PLUGIN_REGISTRATRION_H_
#define PLUGIN_REGISTRATRION_H_

#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"
#include "methods.h"
#include "types.h"

#include <string>
#include <optional>
#include <memory>

struct RegistrationUtils {
	std::shared_ptr<FlutterMap> launchData;
	std::shared_ptr<PluginMethodChannel> channel;
	std::shared_ptr<bool> didLaunchWithNotification;
};

/// <summary>
/// Registers the running app to the Windows Registry.
/// </summary>
/// <param name="aumid">The app user model ID that identifies the app.</param>
/// <param name="appName">The display name of the app.</param>
/// <param name="guid">The display name of the app.</param>
/// <param name="iconPath">An optional path to the icon of the app.</param>
/// <param name="iconBgColor">An optional background color of the icon, in AARRGGBB format.</param>
/// <param name="plugin">The instance of the plugin calling this function</param>
bool RegisterApp(
	const std::string& aumid,
	const std::string& appName,
	const std::string& guid,
	const std::optional<std::string>& iconPath,
	const std::optional<std::string>& iconBgColor,
	std::shared_ptr<RegistrationUtils> utils
);

#endif // !PLUGIN_REGISTRATRION_H_
