export "details/initialization_settings.dart";
export "details/notification_action.dart";
export "details/notification_audio.dart";
export "details/notification_details.dart";
export "details/notification_row.dart";
export "details/notification_header.dart";
export "details/notification_image.dart";
export "details/notification_input.dart";
export "details/notification_part.dart";
export "details/notification_progress.dart";
export "details/notification_text.dart";
export "details/notification_to_xml.dart";

/// The result of updating a notification.
enum NotificationUpdateResult {
  /// The update was successful.
  success,
  /// There was an unexpected error updating the notification.
  error,
  /// No notification with the provided ID could be found.
  notFound,
}
