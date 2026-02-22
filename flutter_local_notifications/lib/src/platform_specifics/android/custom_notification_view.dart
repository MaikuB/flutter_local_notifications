/// Represents a mapping between a view ID and its associated data.
///
/// This class is used to configure custom notification views by mapping
/// Android view IDs to their corresponding text content or action IDs.
///
/// Example:
/// ```dart
/// CustomViewMapping(
///   viewId: 'notification_title',
///   text: 'Hello from Flutter',
/// )
/// ```
class CustomViewMapping {
  /// Creates a [CustomViewMapping] with the specified view ID and optional
  /// text and action ID.
  ///
  /// [viewId] is the Android resource ID name (e.g., 'button_action', 'text_title')
  /// [text] is the text content to set on the view (for TextViews)
  /// [actionId] is the action identifier for clickable views (for Buttons)
  const CustomViewMapping({
    required this.viewId,
    this.text,
    this.actionId,
  });

  /// The Android resource ID name of the view.
  ///
  /// This should match the ID defined in your XML layout file.
  /// Example: 'button_action', 'text_title', 'image_icon'
  final String viewId;

  /// The text content to display in the view.
  ///
  /// This is typically used for TextView elements where you want to
  /// dynamically set the text from Flutter.
  final String? text;

  /// The action identifier for clickable views.
  ///
  /// When the view is clicked, this action ID will be sent back to Flutter
  /// through the notification callback, allowing you to handle the action.
  final String? actionId;

  /// Converts this mapping to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'viewId': viewId,
      if (text != null) 'text': text,
      if (actionId != null) 'actionId': actionId,
    };
  }
}

/// Configuration for a custom notification view layout.
///
/// This class allows you to specify a custom Android XML layout for
/// notifications and configure the views within that layout.
///
/// Example:
/// ```dart
/// AndroidNotificationDetails(
///   'channel_id',
///   'channel_name',
///   customContentView: CustomNotificationView(
///     layoutName: 'custom_notification',
///     viewMappings: [
///       CustomViewMapping(viewId: 'title', text: 'Title'),
///       CustomViewMapping(viewId: 'button', text: 'Click', actionId: 'btn_action'),
///     ],
///   ),
///   customBigContentView: CustomNotificationView(
///     layoutName: 'custom_notification_expanded',
///     viewMappings: [...],
///   ),
///   customHeadsUpContentView: CustomNotificationView(
///     layoutName: 'custom_notification_headsup',
///     viewMappings: [...],
///   ),
/// )
/// ```
class CustomNotificationView {
  /// Creates a [CustomNotificationView] with the specified layout and mappings.
  ///
  /// [layoutName] is the name of the Android XML layout resource
  /// [viewMappings] is a list of view configurations for the layout
  const CustomNotificationView({
    required this.layoutName,
    this.viewMappings = const <CustomViewMapping>[],
  });

  /// The name of the Android XML layout resource.
  ///
  /// This should match the layout file name without the .xml extension.
  /// Example: 'custom_notification_layout'
  final String layoutName;

  /// List of view mappings that configure the views in the layout.
  ///
  /// Each mapping specifies how to configure a specific view in the layout,
  /// such as setting text content or attaching click actions.
  final List<CustomViewMapping> viewMappings;

  /// Converts this view configuration to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'layoutName': layoutName,
      'viewMappings': viewMappings.map((m) => m.toMap()).toList(),
    };
  }
}
