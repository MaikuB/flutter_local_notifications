/// Plugin initialization settings for iOS
class InitializationSettingsIOS {
  /// Request permission to display an alert
  final bool requestAlertPermission;

  /// Request permission to play a sound
  final bool requestSoundPermission;

  /// Request permission to badge app icon
  final bool requestBadgePermission;

  /// Display an alert when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentAlert;

  /// Play a sound when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentSound;

  /// Apply the badge value when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentBadge;

  const InitializationSettingsIOS({this.requestAlertPermission = true, this.requestSoundPermission = true, this.requestBadgePermission = true, this.presentAlert = true, this.presentSound = true, this.presentBadge = true});

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'requestAlertPermission': requestAlertPermission,
      'requestSoundPermission': requestSoundPermission,
      'requestBadgePermission': requestBadgePermission,
      'presentAlert': presentAlert,
      'presentSound': presentSound,
      'presentBadge': presentBadge
    };
  }
}