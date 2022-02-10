import 'initialization_settings.dart';

/// An extension on [WindowsInitializationSettings] that provides mapping
/// to method channel serializable values.
extension WindowsInitializationSettingsMapper on WindowsInitializationSettings {
  /// Maps [WindowsInitializationSettings] to a [Map].
  Map<String, dynamic> toMap() => <String, dynamic>{
        'appName': appName,
      };
}
