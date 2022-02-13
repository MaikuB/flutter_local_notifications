#ifndef PLUGIN_REGISTRATRION_H_
#define PLUGIN_REGISTRATRION_H_

#include <string>
#include <optional>

namespace PluginRegistration {
	/// <summary>
	/// Registers the running app to the Windows Registry.
	/// </summary>
	/// <param name="aumid">The app user model ID that identifies the app.</param>
	/// <param name="appName">The display name of the app.</param>
	/// <param name="iconPath">An optional path to the icon of the app.</param>
	/// <param name="iconBgColor">An optional background color of the icon, in AARRGGBB format.</param>
	void RegisterApp(
		const std::string& aumid,
		const std::string& appName,
		const std::optional<std::string>& iconPath,
		const std::optional<std::string>& iconBgColor);
}

#endif // !PLUGIN_REGISTRATRION_H_
