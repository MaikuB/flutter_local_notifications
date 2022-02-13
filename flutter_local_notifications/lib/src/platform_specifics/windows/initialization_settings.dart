import 'package:flutter/widgets.dart';

/// Plugin initialization settings for Windows.
class WindowsInitializationSettings {
  /// Creates a new settings object for initializing this plugin on Windows.
  const WindowsInitializationSettings({
    required this.appName,
    required this.appUserModelId,
    this.iconPath,
    this.iconBackgroundColor,
  });

  /// The name of the app that should be shown in the notification toast.
  final String appName;

  /// The unique app user model ID that identifies the app,
  /// in the form of CompanyName.ProductName.SubProduct.VersionInformation.
  ///
  /// See https://docs.microsoft.com/en-us/windows/win32/shell/appids
  /// for more information.
  final String appUserModelId;

  final String? iconPath;

  final Color? iconBackgroundColor;
}
