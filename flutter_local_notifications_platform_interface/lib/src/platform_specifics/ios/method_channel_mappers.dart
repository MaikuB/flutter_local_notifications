import 'initialization_settings.dart';
import 'notification_attachment.dart';
import 'notification_details.dart';

// ignore_for_file: public_member_api_docs
extension IOSInitializationSettingsMapper on IOSInitializationSettings {
  Map<String, Object> toMap() => <String, Object>{
        'requestAlertPermission': requestAlertPermission,
        'requestSoundPermission': requestSoundPermission,
        'requestBadgePermission': requestBadgePermission,
        'defaultPresentAlert': defaultPresentAlert,
        'defaultPresentSound': defaultPresentSound,
        'defaultPresentBadge': defaultPresentBadge
      };
}

extension IOSNotificationAttachmentMapper on IOSNotificationAttachment {
  Map<String, Object> toMap() => <String, Object>{
        'identifier': identifier ?? '',
        'filePath': filePath,
      };
}

extension IOSNotificationDetailsMapper on IOSNotificationDetails {
  Map<String, Object?> toMap() => <String, Object?>{
        'presentAlert': presentAlert,
        'presentSound': presentSound,
        'presentBadge': presentBadge,
        'subtitle': subtitle,
        'sound': sound,
        'badgeNumber': badgeNumber,
        'threadIdentifier': threadIdentifier,
        'attachments': attachments
            ?.map((a) => a.toMap()) // ignore: always_specify_types
            .toList()
      };
}
