import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'padded_button.dart';
import 'plugin.dart';

List<Widget> webExamples(bool? hasPermission) => <Widget>[
      const Text(
        'Web-specific examples',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (hasPermission ?? false)
        const Text('Notification permissions granted')
      else
        const Text(
          'WARNING: The user did not grant permissions to show notifications',
        ),
      const PaddedElevatedButton(
        buttonText: 'Notification with images',
        onPressed: _showImages,
      ),
      const PaddedElevatedButton(
        buttonText: 'Right-to-left notification',
        onPressed: _showRtl,
      ),
      const PaddedElevatedButton(
        buttonText: 'Require interaction',
        onPressed: _showInteraction,
      ),
      const PaddedElevatedButton(
        buttonText: 'Replace notification',
        onPressed: _showRenotify,
      ),
      const PaddedElevatedButton(
        buttonText: 'Notification with an older timestamp',
        onPressed: _showTimestamp,
      ),
      const PaddedElevatedButton(
        buttonText: 'Notification with vibration',
        onPressed: _showVibrate,
      ),
    ];

final Uri imageUrl = Uri.parse('https://picsum.photos/500');
final Uri iconUrl = Uri.parse('https://picsum.photos/100');
final Uri badgeUrl =
    Uri.parse(AssetManager().getAssetUrl('icons/app_icon_density.png'));

Future<void> showDetails(WebNotificationDetails details) =>
    flutterLocalNotificationsPlugin.show(
      id: id++,
      title: 'This is a title',
      body: 'This is a body',
      notificationDetails: NotificationDetails(web: details),
    );

void _showTimestamp() =>
    showDetails(WebNotificationDetails(timestamp: DateTime(2020, 1, 5)));

Future<void> _showRenotify() async {
  final int id2 = id++;
  await flutterLocalNotificationsPlugin.show(
    id: id2,
    title: 'This is the original notification!',
    body: 'Wait for it...',
    notificationDetails: const NotificationDetails(web: WebNotificationDetails(renotify: true)),
  );
  await Future<void>.delayed(const Duration(seconds: 1));
  await flutterLocalNotificationsPlugin.show(
    id: id2,
    title: 'This is the replacement!',
    body: 'Notice there is no animation!',
  );
}

void _showInteraction() =>
    showDetails(const WebNotificationDetails(requireInteraction: true));

void _showImages() => showDetails(WebNotificationDetails(
      imageUrl: imageUrl,
      iconUrl: iconUrl,
      badgeUrl: iconUrl,
    ));

void _showRtl() => flutterLocalNotificationsPlugin.show(
      id: id++,
      title: 'This is in a right-to-left language',
      body: 'שלום חביבי!',
      notificationDetails: const NotificationDetails(
        web: WebNotificationDetails(
          direction: WebNotificationDirection.rightToLeft,
        ),
      ),
    );

// Star wars theme!
// See: https://tests.peter.sh/notification-generator/
final List<int> vibrationPattern = <int>[
  500,
  110,
  500,
  110,
  450,
  110,
  200,
  110,
  170,
  40,
  450,
  110,
  200,
  110,
  170,
  40,
  500,
];
void _showVibrate() => showDetails(WebNotificationDetails(
      vibrationPattern: vibrationPattern,
    ));
