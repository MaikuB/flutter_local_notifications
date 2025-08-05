/// The available intervals for periodically showing notifications.
enum RepeatInterval {
  /// An interval for every minute.
  everyMinute,

  /// Hourly interval.
  hourly,

  /// Daily interval.
  daily,

  /// Weekly interval.
  weekly
}

/// Details of a pending notification that has not been delivered.
class PendingNotificationRequest {
  /// Constructs an instance of [PendingNotificationRequest].
  const PendingNotificationRequest(
      this.id, this.title, this.body, this.payload);

  /// The notification's id.
  final int id;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  final String? payload;
}

/// Details of an active notification.
class ActiveNotification {
  /// Constructs an instance of [ActiveNotification].
  const ActiveNotification({
    this.id,
    this.groupKey,
    this.channelId,
    this.title,
    this.body,
    this.payload,
    this.tag,
    this.bigText,
  });

  /// The notification's id.
  ///
  /// This will be null if the notification was outsided of the plugin's
  /// control e.g. on iOS and via Firebase Cloud Messaging.
  final int? id;

  /// The notification's channel id.
  ///
  /// Returned only on Android 8.0 or newer.
  final String? channelId;

  /// The notification's group.
  ///
  /// Returned only on Android.
  final String? groupKey;

  /// The notification's title.
  final String? title;

  /// The notification's body.
  final String? body;

  /// The notification's payload.
  ///
  /// Returned only on iOS and macOS.
  final String? payload;

  /// The notification's tag.
  ///
  /// Returned only on Android.
  final String? tag;

  /// The notification's longer text displayed using big text style.
  ///
  /// Returned only on Android.
  final String? bigText;
}

/// Details of a Notification Action that was triggered.
class NotificationResponse {
  /// Constructs an instance of [NotificationResponse]
  const NotificationResponse({
    required this.notificationResponseType,
    this.id,
    this.actionId,
    this.input,
    this.payload,
    this.data = const <String, dynamic>{},
  });

  /// The notification's id.
  ///
  /// This is nullable as support for this only supported for notifications
  /// created using version 10 or newer of this plugin.
  final int? id;

  /// The id of the action that was triggered.
  final String? actionId;

  /// The value of the input field if the notification action had an input
  /// field.
  ///
  /// On Windows, this is always null. Instead, [data] holds the values of
  /// each input with the input's ID as the key.
  final String? input;

  /// The notification's payload.
  final String? payload;

  /// Any other data returned by the platform.
  ///
  /// Returned only on Windows.
  final Map<String, dynamic> data;

  /// The notification response type.
  final NotificationResponseType notificationResponseType;
}

/// Contains details on the notification that launched the application.
class NotificationAppLaunchDetails {
  /// Constructs an instance of [NotificationAppLaunchDetails].
  const NotificationAppLaunchDetails(
    this.didNotificationLaunchApp, {
    this.notificationResponse,
  });

  /// Indicates if the app was launched via notification.
  final bool didNotificationLaunchApp;

  /// Contains details of the notification that launched the app.
  final NotificationResponse? notificationResponse;
}

/// The possible notification response types
enum NotificationResponseType {
  /// Indicates that a user has selected a notification.
  selectedNotification,

  /// Indicates the a user has selected a notification action.
  selectedNotificationAction,
}
