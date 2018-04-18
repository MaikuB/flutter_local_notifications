import 'package:flutter_local_notifications/platform_specifics/android/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/ios/initialization_settings_ios.dart';

/// Settings for initializing the plugin for each platform
class InitializationSettings {
  /// Settings for Android
  final InitializationSettingsAndroid android;

  /// Settings for iOS
  final InitializationSettingsIOS ios;

  const InitializationSettings(this.android, this.ios);
}
