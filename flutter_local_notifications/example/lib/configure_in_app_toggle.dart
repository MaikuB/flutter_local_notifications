import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A widget that displays a toggle for enabling the "Configure in App" option
/// for iOS notifications (iOS 12+ only).
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
  bool _isIOS12OrHigher = false;

  @override
  void initState() {
    super.initState();
    _checkIOSVersion();
  }

  /// Checks if the device is running iOS 12 or higher.
  Future<void> _checkIOSVersion() async {
    if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final List<String> version = iosInfo.systemVersion.split('.');
      if (version.isNotEmpty) {
        final int? majorVersion = int.tryParse(version[0]);
        setState(() {
          _isIOS12OrHigher = majorVersion != null && majorVersion >= 12;
        });
      }
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
• To access: view a notification on the lock screen, swipe left, and tap 'Options'
• Requests 'providesAppNotificationSettings' permission (iOS 12+)
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
                future: widget.flutterLocalNotificationsPlugin
                    .resolvePlatformSpecificImplementation<
                        IOSFlutterLocalNotificationsPlugin>()
                    ?.checkPermissions(),
                builder: (BuildContext context,
                    AsyncSnapshot<NotificationsEnabledOptions?> snapshot) {
                  final bool enabled =
                      snapshot.data?.isProvidesAppNotificationSettingsEnabled ??
                          false;
                  return Switch(
                    value: enabled,
                    onChanged: !Platform.isIOS || !_isIOS12OrHigher || enabled
                        ? null
                        : (bool value) async {
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
                              setState(() {});
                            }
                          },
                  );
                },
              ),
            ),
          ],
        ),
      );
}
