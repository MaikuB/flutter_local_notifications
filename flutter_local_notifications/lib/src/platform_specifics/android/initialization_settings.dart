/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  const AndroidInitializationSettings(this.defaultIcon);

  /// Specifies the default icon for notifications.
  final String defaultIcon;

  /// Creates a [Map] object that describes the [AndroidInitializationSettings] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, Object> toMap() {
    return <String, Object>{'defaultIcon': this.defaultIcon};
  }
}
