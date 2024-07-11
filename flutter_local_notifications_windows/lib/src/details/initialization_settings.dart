/// Plugin initialization settings for Windows.
class WindowsInitializationSettings {
  /// Creates a new settings object for initializing this plugin on Windows.
  const WindowsInitializationSettings({
    required this.appName,
    required this.appUserModelId,
    required this.guid,
    this.iconPath,
  });

  /// The name of the app that should be shown in the notification toast.
  final String appName;

  /// The unique app user model ID that identifies the app,
  /// in the form of CompanyName.ProductName.SubProduct.VersionInformation.
  ///
  /// See https://docs.microsoft.com/en-us/windows/win32/shell/appids
  /// for more information.
  final String appUserModelId;

  /// The GUID that identifies the notification activation callback.
  final String guid;

  /// The path to the icon of the notification.
  final String? iconPath;
}
