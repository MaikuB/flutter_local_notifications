/// Configures the notification details on iOS.
class IOSNotificationDetails {
  // Display an alert when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentAlert;

  /// Play a sound when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentSound;

  /// Apply the badge value when the notification is triggered while app is in the foreground. iOS 10+ only
  final bool presentBadge;

  /// Specifies the name of the file to play for the notification. Requires setting [presentSound] to true. If [presentSound] is set to true but [sound] isn't specified then it will use the default notification sound.
  final String sound;

  /// Specify the number to display as the app icon's badge when the notification arrives.
  /// Specify the number 0 to remove the current badge, if present. Greater than 0 to display a badge with that number.
  /// Specify null to leave the current badge unchanged.
  final int badgeNumber;

  IOSNotificationDetails(
      {this.presentAlert,
      this.presentBadge,
      this.presentSound,
      this.sound,
      this.badgeNumber});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'presentAlert': presentAlert,
      'presentSound': presentSound,
      'presentBadge': presentBadge,
      'sound': sound,
      'badgeNumber': badgeNumber,
    };
  }
}
