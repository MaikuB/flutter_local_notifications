import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A widget that displays a toggle for enabling the "Configure in App" option
/// for iOS and macOS notifications.
class ConfigureInAppToggle extends StatefulWidget {
  /// Creates a ConfigureInAppToggle widget.
  const ConfigureInAppToggle({
    required this.flutterLocalNotificationsPlugin,
    Key? key,
  }) : super(key: key);

  /// The FlutterLocalNotificationsPlugin instance.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  State<ConfigureInAppToggle> createState() => _ConfigureInAppToggleState();
}

class _ConfigureInAppToggleState extends State<ConfigureInAppToggle> {
  bool _isSupportedVersion = false;

  @override
  void initState() {
    super.initState();
    _checkPlatformVersion();
  }

  /// Checks if the device is running a supported OS version.
  /// iOS 12.0+ or macOS 10.14+
  Future<void> _checkPlatformVersion() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final List<String> version = iosInfo.systemVersion.split('.');
      if (version.isNotEmpty) {
        final int? majorVersion = int.tryParse(version[0]);
        setState(() {
          _isSupportedVersion = majorVersion != null && majorVersion >= 12;
        });
      }
    } else if (Platform.isMacOS) {
      final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
      final int version = macInfo.majorVersion;
      final int minorVersion = macInfo.minorVersion;
      setState(() {
        _isSupportedVersion =
            version > 10 || (version == 10 && minorVersion >= 14);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 4, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Show 'Configure in App' context menu option:",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '''
• iOS: swipe left on a notification and tap 'Options'
• macOS: right-click on a notification
• Requests 'providesAppNotificationSettings' permission (iOS 12+ / macOS 10.14+)
• Tap is handled by 'userNotificationCenter(_:openSettingsFor:)' delegate method (not provided by plugin)
• Note: Once enabled, this declaration cannot be revoked''',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FutureBuilder<NotificationsEnabledOptions?>(
                future: Platform.isIOS
                    ? widget.flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                            IOSFlutterLocalNotificationsPlugin>()
                        ?.checkPermissions()
                    : widget.flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                            MacOSFlutterLocalNotificationsPlugin>()
                        ?.checkPermissions(),
                builder: (BuildContext context,
                    AsyncSnapshot<NotificationsEnabledOptions?> snapshot) {
                  final bool enabled =
                      snapshot.data?.isProvidesAppNotificationSettingsEnabled ??
                          false;
                  return Switch(
                    value: enabled,
                    onChanged: !_isSupportedVersion || enabled
                        ? null
                        : (bool value) async {
                            if (Platform.isIOS) {
                              final IOSFlutterLocalNotificationsPlugin? plugin =
                                  widget.flutterLocalNotificationsPlugin
                                      .resolvePlatformSpecificImplementation<
                                          IOSFlutterLocalNotificationsPlugin>();
                              if (plugin != null) {
                                await plugin.requestPermissions(
                                  alert: true,
                                  badge: true,
                                  sound: true,
                                  providesAppNotificationSettings: true,
                                );
                              }
                            } else if (Platform.isMacOS) {
                              final MacOSFlutterLocalNotificationsPlugin?
                                  plugin = widget
                                      .flutterLocalNotificationsPlugin
                                      .resolvePlatformSpecificImplementation<
                                          MacOSFlutterLocalNotificationsPlugin>();
                              if (plugin != null) {
                                await plugin.requestPermissions(
                                  alert: true,
                                  badge: true,
                                  sound: true,
                                  providesAppNotificationSettings: true,
                                );
                              }
                            }
                            setState(() {});
                          },
                  );
                },
              ),
            ),
          ],
        ),
      );
}
