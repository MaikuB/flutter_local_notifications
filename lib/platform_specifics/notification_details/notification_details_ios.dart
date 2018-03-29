/// Configures the notification details on iOS. 
/// Currently not used.
class NotificationDetailsIOS {
    /// Display an alert when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentAlert;

  /// Play a sound when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentSound;

  /// Apply the badge value when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentBadge;

  final String sound;
  
  NotificationDetailsIOS({this.presentAlert, this.presentBadge, this.presentSound, this.sound});

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'presentAlert': presentAlert,
      'presentSound': presentSound,
      'presentBadge': presentBadge,
      'sound': sound
    };
  }
}