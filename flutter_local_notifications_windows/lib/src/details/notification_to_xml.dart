import 'package:xml/xml.dart';

import '../../flutter_local_notifications_windows.dart';
import 'xml/details.dart';

extension on DateTime {
  String toIso8601StringTz() {
    // Get offset
    final Duration offset = timeZoneOffset;
    final String sign = offset.isNegative ? '-' : '+';
    final String hours = offset.inHours.abs().toString().padLeft(2, '0');
    final String minutes =
      offset.inMinutes.abs().remainder(60).toString().padLeft(2, '0');
    final String offsetString = '$sign$hours:$minutes';
    // Get first part of properly formatted ISO 8601 date
    final String formattedDate = toIso8601String().split('.').first;
    return '$formattedDate$offsetString';
  }
}

extension on WindowsNotificationDetails {
  /// XML attributes for the toast notification as a whole.
  Map<String, String> get attributes => <String, String>{
    if (duration != null) 'duration': duration!.name,
    if (timestamp != null)
      'displayTimestamp': timestamp!.toIso8601StringTz(),
    if (scenario != null) 'scenario': scenario!.name,
  };
}

/// Extensions on [WindowsProgressBar].
extension ProgressBarXml on WindowsProgressBar {
  /// The data bindings for this progress bar.
  ///
  /// To support dynamic updates, [buildXml] will inject placeholder strings
  /// called data bindings instead of actual values. This can then be updated
  /// dynamically later by calling
  /// [FlutterLocalNotificationsWindows.updateProgressBar].
  Map<String, String> get data => <String, String>{
    '$id-progressValue': value?.toString() ?? 'indeterminate',
    if (label != null) '$id-progressString': label!,
  };
}

/// Converts a notification with [WindowsNotificationDetails] into XML.
///
/// For more details, refer to the [Toast Notification XML schema](https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root).
String notificationToXml({
  String? title,
  String? body,
  String? payload,
  WindowsNotificationDetails? details,
}) {
  final XmlBuilder builder = XmlBuilder();
  builder.element(
    'toast',
    attributes: <String, String>{
      ...details?.attributes ?? <String, String>{},
      if (payload != null) 'launch': payload,
      if (details?.scenario == null) 'useButtonStyle': 'true',
    },
    nest: () {
      builder.element(
        'visual',
        nest: () {
          builder.element(
            'binding',
            attributes: <String, String>{'template': 'ToastGeneric'},
            nest: () {
              builder
                ..element('text', nest: title)
                ..element('text', nest: body);
              details?.generateBinding(builder);
            },
          );
        },
      );
      details?.buildXml(builder);
    },
  );
  return builder
    .buildDocument()
    .toXmlString(pretty: true, indentAttribute: (_) => true);
}
