/// Plugin initialization settings for iOS
class InitializationSettingsIOS {
  /// Indicates if the app will display an alert
  final bool alert;
  /// Indicates if the app will play a sound
  final bool sound;
  /// Indicates if the app will badge its icon
  final bool badge;

  const InitializationSettingsIOS({this.alert = true, this.sound = true, this.badge = true});

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'alert': alert,
      'sound': sound,
      'badge': badge
    };
  }
}