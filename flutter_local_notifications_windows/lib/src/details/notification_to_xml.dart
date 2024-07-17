import "package:xml/xml.dart";

import "notification_details.dart";

/// Converts a notification with [WindowsNotificationDetails] into well-formed XML.
///
/// For more details, refer to the [Toast Notification XML schema](https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root).
String notificationToXml({
  String? title,
  String? body,
  String? payload,
  WindowsNotificationDetails? details,
}) {
  final builder = XmlBuilder();
  builder.element(
    "toast",
    attributes: {
      ...details?.attributes ?? {},
      if (payload != null) "launch": payload,
      if (details?.scenario == null) "useButtonStyle": "true",
    },
    nest: () {
      builder.element("visual", nest: () {
        builder.element(
          "binding",
          attributes: {"template": "ToastGeneric"},
          nest: () {
            builder.element("text", nest: title);
            builder.element("text", nest: body);
            details?.generateBinding(builder);
          },
        );
      },);
      details?.toXml(builder);
    },
  );
  return builder.buildDocument()
    .toXmlString(pretty: true, indentAttribute: (_) => true);
}
