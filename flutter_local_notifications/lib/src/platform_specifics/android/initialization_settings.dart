/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Constructs an instance of [AndroidInitializationSettings].
  const AndroidInitializationSettings(
    this.defaultIcon, {
    this.flutterActivity,
  });

  /// Specifies the default icon for notifications.
  final String defaultIcon;

  /// Specifies the fully qualified name of the custom Flutter `Activity` to be launched
  /// when the notification is tapped.
  ///
  /// Example: `com.example.ui.HomeFlutterActivity`
  final String? flutterActivity;
}
