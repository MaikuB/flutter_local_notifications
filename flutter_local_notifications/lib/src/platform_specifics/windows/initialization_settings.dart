/// Plugin initialization settings for Windows.
class WindowsInitializationSettings {
  /// Creates a new settings object for initializing this plugin on Windows.
  const WindowsInitializationSettings({
    required this.appName,
  });

  /// The name of the app that should be shown in the notification toast.
  final String appName;
}
