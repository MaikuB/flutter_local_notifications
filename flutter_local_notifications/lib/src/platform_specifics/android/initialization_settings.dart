/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Sets the default icon for notifications.
  final String defaultIcon;

  const AndroidInitializationSettings(this.defaultIcon);

  /// Create a [Map] object that describes the [AndroidInitializationSettings] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'defaultIcon': this.defaultIcon};
  }
}
