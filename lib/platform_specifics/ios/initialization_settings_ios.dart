/// Plugin initialization settings for iOS
class InitializationSettingsIOS {
  /// Request permission to display an alert
  final bool requestAlertPermission;

  /// Request permission to play a sound
  final bool requestSoundPermission;

  /// Request permission to badge app icon
  final bool requestBadgePermission;

  /// Default setting that indiciates an alert should be displayed when a notification is triggered while app is in the foreground. iOS 10+ only
  final bool defaultPresentAlert;

  /// Default setting that indiciates if a sound should be played when a notification is triggered while app is in the foreground. iOS 10+ only
  final bool defaultPresentSound;

  /// Default setting that indicates if a badge value should be applied when a notification is triggered while app is in the foreground. iOS 10+ only
  final bool defaultPresentBadge;

  /// Indicates if this plugin should handle incoming notifications and their related actions
  final bool registerUNUserNotificationCenterDelegate;

  const InitializationSettingsIOS(
      {this.requestAlertPermission = true,
      this.requestSoundPermission = true,
      this.requestBadgePermission = true,
      this.defaultPresentAlert = true,
      this.defaultPresentSound = true,
      this.defaultPresentBadge = true,
      this.registerUNUserNotificationCenterDelegate = true});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requestAlertPermission': requestAlertPermission,
      'requestSoundPermission': requestSoundPermission,
      'requestBadgePermission': requestBadgePermission,
      'defaultPresentAlert': defaultPresentAlert,
      'defaultPresentSound': defaultPresentSound,
      'defaultPresentBadge': defaultPresentBadge,
      'registerUNUserNotificationCenterDelegate':
          registerUNUserNotificationCenterDelegate
    };
  }
}
