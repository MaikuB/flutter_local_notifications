import 'package:xml/xml.dart';

import '../notification_action.dart';
import '../notification_details.dart';
import '../notification_input.dart';
import '../notification_progress.dart';
import '../notification_row.dart';

import 'action.dart';
import 'audio.dart';
import 'header.dart';
import 'image.dart';
import 'input.dart';
import 'progress.dart';
import 'row.dart';

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

/// Converts a [WindowsNotificationDetails] to XML
extension DetailsToXml on WindowsNotificationDetails {
  /// Builds all relevant XML parts under the root `<toast>` element.
  void buildXml(XmlBuilder builder) {
    if (actions.length > 5) {
      throw ArgumentError(
        'WindowsNotificationDetails can only have up to 5 actions',
      );
    }
    if (inputs.length > 5) {
      throw ArgumentError(
        'WindowsNotificationDetails can only have up to 5 inputs',
      );
    }
    builder.element(
      'actions',
      nest: () {
        for (final WindowsInput input in inputs) {
          switch (input) {
            case WindowsTextInput():
              input.buildXml(builder);
            case WindowsSelectionInput():
              input.buildXml(builder);
          }
        }
        for (final WindowsAction action in actions) {
          action.buildXml(builder);
        }
      },
    );
    audio?.buildXml(builder);
    header?.buildXml(builder);
  }

  /// Generates the `<binding>` element of the notification.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-binding
  void generateBinding(XmlBuilder builder) {
    if (subtitle != null) {
      builder.element('text', nest: subtitle);
    }
    for (final WindowsImage image in images) {
      image.buildXml(builder);
    }
    for (final WindowsRow row in rows) {
      row.buildXml(builder);
    }
    for (final WindowsProgressBar progressBar in progressBars) {
      progressBar.buildXml(builder);
    }
  }

  /// XML attributes for the toast notification as a whole.
  Map<String, String> get attributes => <String, String>{
        if (duration != null) 'duration': duration!.name,
        if (timestamp != null)
          'displayTimestamp': timestamp!.toIso8601StringTz(),
        if (scenario != null) 'scenario': scenario!.name,
      };
}
