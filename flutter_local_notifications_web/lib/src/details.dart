import 'action.dart';
import 'direction.dart';

export 'action.dart';
export 'direction.dart';

class WebNotificationDetails {
  const WebNotificationDetails({
    this.actions = const <WebNotificationAction>[],
    this.direction = WebNotificationDirection.auto,
    this.badgeUrl,
    this.body,
    this.iconUrl,
    this.lang,
    this.requireInteraction = false,
    this.isSilent = false,
    this.tag,
    this.imageUrl,
    this.renotify = false,
    this.timestamp,
    this.vibrationPattern,
  });

  final List<WebNotificationAction> actions;
  final WebNotificationDirection direction;
  final Uri? badgeUrl;
  final String? body;
  final Uri? iconUrl;
  final Uri? imageUrl;
  final String? lang;
  final bool requireInteraction;
  final bool isSilent;
  final String? tag;
  final bool renotify;
  final DateTime? timestamp;
  final List<Duration>? vibrationPattern;
}
