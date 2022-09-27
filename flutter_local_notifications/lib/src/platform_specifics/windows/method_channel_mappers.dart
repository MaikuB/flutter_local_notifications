import 'initialization_settings.dart';
import 'notification_details.dart';

/// An extension on [WindowsInitializationSettings] that provides mapping
/// to method channel serializable values.
extension WindowsInitializationSettingsMapper on WindowsInitializationSettings {
  /// Maps [WindowsInitializationSettings] to a [Map].
  Map<String, dynamic> toMap() => <String, dynamic>{
        'appName': appName,
        'aumid': appUserModelId,
        'guid': guid,
        'iconPath': iconPath,
        'iconBgColor': iconBackgroundColor,
      };
}

/// An extension on [WindowsNotificationDetails] that provides mapping
/// to method channel serializable values.
extension WindowsNotificationDetailsMapper on WindowsNotificationDetails {
  /// Maps [WindowsNotificationDetails] to a [Map].
  Map<String, dynamic> toMap() => <String, dynamic>{
        'rawXml': rawXml,
      };
}
