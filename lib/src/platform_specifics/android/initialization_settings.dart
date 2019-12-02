import '../../../flutter_local_notifications.dart';

/// Plugin initialization settings for Android
class AndroidInitializationSettings {
  /// Sets the default icon for notifications
  final String defaultIcon;
  /// Callback that is triggered when the user taps on an action
  final OnNotificationActionTappedCallback onNotificationActionTapped;

  const AndroidInitializationSettings(this.defaultIcon, {
    this.onNotificationActionTapped
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'defaultIcon': this.defaultIcon};
  }
}
