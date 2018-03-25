import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/initialization_settings/initialization_settings_ios.dart';


/// Settings for initializing the plugin for each platform
class InitializationSettings{
  final InitializationSettingsAndroid android;
  final InitializationSettingsIOS ios;

  const InitializationSettings(this.android, this.ios);
}