import 'package:flutter/foundation.dart';

/// This represents an action on a button in the android context.
class AndroidNotificationAction {
  /// The icon to display with the button (can be null).
  String icon;

  /// The text in the button itself.
  String text;

  /// The payload to send back to the system when the button is pushed.
  String payload;

  AndroidNotificationAction({this.icon, @required this.text, this.payload});
}
