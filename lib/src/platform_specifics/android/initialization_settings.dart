part of flutter_local_notifications;

/// Plugin initialization settings for Android
class AndroidInitializationSettings {
  /// Sets the default icon for notifications
  final String defaultIcon;

  const AndroidInitializationSettings(this.defaultIcon);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'defaultIcon': this.defaultIcon};
  }
}
