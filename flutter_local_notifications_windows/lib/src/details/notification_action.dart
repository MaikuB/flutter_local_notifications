import 'notification_parts.dart';

// NOTE: All enum values in this file have Windows RT-specific names.
// If you change their Dart names, be sure to override [Enum.name].

/// Decides how the [WindowsAction] will launch the app.
enum WindowsActivationType {
  /// The application will launch in the foreground (the default).
  foreground,

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
  const WindowsAction({
    required this.content,
    required this.arguments,
    this.activationType = WindowsActivationType.foreground,
    this.activationBehavior = WindowsNotificationBehavior.dismiss,
    this.placement,
    this.imageUri,
    this.inputId,
    this.buttonStyle,
    this.tooltip,
  });

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
  ///
  /// Check the docs for [WindowsImage] for an explanation of supported URIs.
  final Uri? imageUri;

  /// The ID of an input box.
  ///
  /// If provided, this button will be placed next to the specified input.
  final String? inputId;

  /// The style of the button. Null indicates a plain button.
  final WindowsButtonStyle? buttonStyle;

  /// The tooltip, useful if [content] is empty.
  final String? tooltip;
}
