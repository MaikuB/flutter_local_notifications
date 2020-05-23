import 'initialization_settings.dart';
import 'notification_attachment.dart';
import 'notification_details.dart';

extension IOSInitializationSettingsMapper on IOSInitializationSettings {
  Map<String, Object> toMap() {
    return <String, Object>{
      'requestAlertPermission': requestAlertPermission,
      'requestSoundPermission': requestSoundPermission,
      'requestBadgePermission': requestBadgePermission,
      'defaultPresentAlert': defaultPresentAlert,
      'defaultPresentSound': defaultPresentSound,
      'defaultPresentBadge': defaultPresentBadge
    };
  }
}

extension IOSNotificationAttachmentMapper on IOSNotificationAttachment {
  Map<String, Object> toMap() {
    return <String, Object>{
      'identifier': identifier ?? '',
      'filePath': filePath,
    };
  }
}

extension IOSNotificationDetailsMapper on IOSNotificationDetails {
  Map<String, Object> toMap() {
    return <String, Object>{
      'presentAlert': presentAlert,
      'presentSound': presentSound,
      'presentBadge': presentBadge,
      'sound': sound,
      'badgeNumber': badgeNumber,
      'attachments': attachments?.map((a) => a.toMap())?.toList()
    };
  }
}
