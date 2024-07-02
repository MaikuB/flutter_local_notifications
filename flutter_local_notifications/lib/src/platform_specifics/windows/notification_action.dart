import 'dart:io';

import 'package:xml/xml.dart';

// NOTE: All enum values in this file have Windows RT-specific names.
// If you change their Dart names, be sure to override [Enum.name].

/// Decides how the [WindowsAction] will launch the app.
///
/// On desktop platforms, [foreground] and [background] are treated the same.
enum WindowsActivationType {
  /// The application will launch in the foreground (the default).
  foreground,
  /// The application will launch as a background task.
  background,
  /// Any application can be launched using its protocol.
  protocol,
}

/// Decides how a [WindowsAction] will react to being pressed.
enum WindowsNotificationBehavior {
  /// The notification will be dismissed.
  dismiss('default'),
  /// The notification will remain on screen and show a loading status.
  pendingUpdate('pendingUpdate');

  const WindowsNotificationBehavior(this.name);
  /// The Windows API name for this choice.
  final String name;
}

/// Decides how a [WindowsAction] will be styled.
enum WindowsButtonStyle {
  /// A green button.
  success('Success'),
  /// A red button.
  critical('Critical');

  const WindowsButtonStyle(this.name);
  /// The Windows API name for this choice.
  final String name;
}

/// Decides how a [WindowsAction] is placed on a notification.
enum WindowsActionPlacement {
  /// Instead of a separate button, the action is part of the context menu.
  contextMenu,
}

/// A button in a Windows notification.
///
/// See https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action#attributes
class WindowsAction {
  /// Constructs a Windows notification button from parameters.
  WindowsAction({
    required this.content,
    required this.arguments,
    this.activationType = WindowsActivationType.foreground,
    this.activationBehavior = WindowsNotificationBehavior.dismiss,
    this.placement,
    this.image,
    this.inputId,
    this.buttonStyle,
    this.tooltip,
  }) {
    if (image != null && !image!.isAbsolute) {
      throw ArgumentError.value(
        image!.path,
        'WindowsImage.file',
        'File path must be absolute',
      );
    }
  }

  /// The body text of the button.
  final String content;

  /// An app-defined string that will be passed back if the button is pressed.
  final String arguments;

  /// How the application should open if the button is pressed.
  ///
  /// The default value is [WindowsActivationType.foreground].
  final WindowsActivationType activationType;

  /// How the notification should react when the button is pressed.
  ///
  /// The default value is [WindowsNotificationBehavior.dismiss].
  final WindowsNotificationBehavior activationBehavior;

  /// How the button should be placed on the notification.
  ///
  /// Null indicates a regular button.
  final WindowsActionPlacement? placement;

  /// An image to show on the button.
  ///
  /// Images must be white with a transparent background, and should be
  /// 16x16 pixels with no padding. If you provide an image for one button,
  /// you should provide images for all your buttons.
  final File? image;

  /// The ID of an input box.
  ///
  /// If provided, this button will be placed next to the specified input.
  final String? inputId;

  /// The style of the button. Null indicates a plain button.
  final WindowsButtonStyle? buttonStyle;

  /// The tooltip, useful if [content] is empty.
  final String? tooltip;

  /// Serializes this notification action as Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action#syntax
  void toXml(XmlBuilder builder) => builder.element(
    'action',
    attributes: <String, String>{
      'content': content,
      'arguments': arguments,
      'activationType': activationType.name,
      'afterActivationBehavior': activationBehavior.name,
      if (placement != null) 'placement': placement!.name,
      if (image != null) 'imageUri':
        Uri.file(image!.absolute.path, windows: true).toString(),
      if (inputId != null) 'hint-inputId': inputId!,
      if (buttonStyle != null) 'hint-buttonStyle': buttonStyle!.name,
      if (tooltip != null) 'hint-toolTip': tooltip!,
    },
  );
}
