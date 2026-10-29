/// Plugin initialization settings for Windows.
class WindowsInitializationSettings {
  /// Creates a new settings object for initializing this plugin on Windows.
  const WindowsInitializationSettings({
    required this.appName,
    required this.appUserModelId,
    required this.guid,
    this.iconPath,
    this.groupName = 'flnpGroupNull',
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

  /// The group assigned to every notification when the app has no package
  /// identity (i.e. is not packaged as an MSIX).
  ///
  /// Windows requires a group to look up notifications by tag for such apps,
  /// which [cancel] and [getActiveNotifications] rely on. Ignored for apps with
  /// package identity.
  ///
  /// For apps without package identity, this must be between 1 and 64
  /// characters long, otherwise [initialize] throws an [ArgumentError].
  final String groupName;
}
