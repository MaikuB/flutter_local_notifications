import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';

import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/darwin/initialization_settings.dart';

/// Settings for initializing the plugin for each platform.
class InitializationSettings {
  /// Constructs an instance of [InitializationSettings].
  const InitializationSettings({
    this.android,
    this.iOS,
    this.macOS,
    this.linux,
  });

  /// Settings for Android.
  ///
  /// It is nullable, because we don't want to force users to specify settings
  /// for platforms that they don't target.
  final AndroidInitializationSettings? android;

  /// Settings for iOS.
  ///
  /// It is nullable, because we don't want to force users to specify settings
  /// for platforms that they don't target.
  final DarwinInitializationSettings? iOS;

  /// Settings for macOS.
  ///
  /// It is nullable, because we don't want to force users to specify settings
  /// for platforms that they don't target.
  final DarwinInitializationSettings? macOS;

  /// Settings for Linux.
  ///
  /// It is nullable, because we don't want to force users to specify settings
  /// for platforms that they don't target.
  final LinuxInitializationSettings? linux;
}
