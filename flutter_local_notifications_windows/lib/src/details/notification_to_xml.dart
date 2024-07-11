import "package:xml/xml.dart";

import "notification_details.dart";

String notificationToXml({
  String? title,
  String? body,
  String? payload,
  WindowsNotificationDetails? details,
}) {
  final builder = XmlBuilder();
  builder.element(
    "toast",
    attributes: <String, String>{
      ...details?.attributes ?? <String, String>{},
      if (payload != null) "launch": payload,
      if (details?.scenario == null) "useButtonStyle": "true",
    },
    nest: () {
      builder.element("visual", nest: () {
        builder.element(
          "binding",
          attributes: <String, String>{"template": "ToastGeneric"},
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
