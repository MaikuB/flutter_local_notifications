import 'notification_details.dart';

// ignore_for_file: public_member_api_docs
extension MacOSNotificationDetailsMapper on LinuxNotificationDetails {
  Map<String, Object?> toMap() => <String, Object?>{
        'iconPath': iconPath,
        'category': category,
        'urgency': urgency.value,
        'timeout': timeout.value,
      };
}
