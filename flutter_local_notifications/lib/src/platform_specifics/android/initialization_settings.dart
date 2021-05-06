/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  const AndroidInitializationSettings(this.defaultIcon, {this.packageName});

  /// Specifies the default icon for notifications.
  final String defaultIcon;

  /// Specifies the package name for application.
  final String packageName;
}
