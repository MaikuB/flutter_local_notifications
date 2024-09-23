import 'package:xml/xml.dart';

import '../../flutter_local_notifications_windows.dart';
import 'xml/details.dart';

export 'xml/progress.dart';

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
