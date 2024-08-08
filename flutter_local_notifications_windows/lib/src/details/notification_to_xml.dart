import "package:xml/xml.dart";

import "notification_details.dart";

extension on DateTime {
  String toIso8601StringTz() {
    // Get offset
    final offset = timeZoneOffset;
    final sign = offset.isNegative ? "-" : "+";
    final hours = offset.inHours.abs().toString().padLeft(2, "0");
    final minutes = offset.inMinutes.abs().remainder(60).toString().padLeft(2, "0");
    final offsetString = "$sign$hours:$minutes";
    // Get first part of properly formatted ISO 8601 date
    final formattedDate = toIso8601String().split(".").first;
    return "$formattedDate$offsetString";
  }
}

extension on WindowsNotificationDetails {
  /// XML attributes for the toast notification as a whole.
  Map<String, String> get attributes => {
    if (duration != null) "duration": duration!.name,
    if (timestamp != null) "displayTimestamp": timestamp!.toIso8601StringTz(),
    if (scenario != null) "scenario": scenario!.name,
  };
}

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
