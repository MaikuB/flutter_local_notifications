import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_android.dart';
import 'package:flutter_local_notifications/platform_specifics/notification_details/notification_details_ios.dart';

/// Contains notification settings for each platform
class NotificationDetails {
  final NotificationDetailsAndroid android;
  final NotificationDetailsIOS iOS;
  const NotificationDetails(this.android, this.iOS);
}
