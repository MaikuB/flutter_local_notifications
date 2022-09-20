import 'package:flutter/foundation.dart';

/// Categories of notifications.
@immutable
class LinuxNotificationCategory {
  /// Constructs an instance of [LinuxNotificationCategory]
  /// with a given [name] of category.
  const LinuxNotificationCategory(this.name);

  /// A generic device-related notification
  /// that doesn't fit into any other category.
  static const LinuxNotificationCategory device =
      LinuxNotificationCategory('device');

  /// A device, such as a USB device, was added to the system.
  static const LinuxNotificationCategory deviceAdded =
      LinuxNotificationCategory('device.added');

  /// A device had some kind of error.
  static const LinuxNotificationCategory deviceError =
      LinuxNotificationCategory('device.error');

  /// A device, such as a USB device, was removed from the system.
  static const LinuxNotificationCategory deviceRemoved =
      LinuxNotificationCategory('device.removed');

  /// A generic e-mail-related notification
  /// that doesn't fit into any other category.
  static const LinuxNotificationCategory email =
      LinuxNotificationCategory('email');

  /// A new e-mail notification.
  static const LinuxNotificationCategory emailArrived =
      LinuxNotificationCategory('email.arrived');

  /// A notification stating that an e-mail has bounced.
  static const LinuxNotificationCategory emailBounced =
      LinuxNotificationCategory('email.bounced');

  /// A generic instant message-related notification
  /// that doesn't fit into any other
  static const LinuxNotificationCategory im = LinuxNotificationCategory('im');

  /// An instant message error notification.
  static const LinuxNotificationCategory imError =
      LinuxNotificationCategory('im.error');

  /// A received instant message notification.
  static const LinuxNotificationCategory imReceived =
      LinuxNotificationCategory('im.received');

  /// A generic network notification that
  /// doesn't fit into any other category.
  static const LinuxNotificationCategory network =
      LinuxNotificationCategory('network');

  /// A network connection notification,
  /// such as successful sign-on to a network service.
  /// This should not be confused with
  /// [deviceAdded] for new network devices.
  static const LinuxNotificationCategory networkConnected =
      LinuxNotificationCategory('network.connected');

  /// A network disconnected notification.
  /// This should not be confused with [deviceRemoved]
  /// for disconnected network devices.
  static const LinuxNotificationCategory networkDisconnected =
      LinuxNotificationCategory('network.disconnected');

  /// A network-related or connection-related error.
  static const LinuxNotificationCategory networkError =
      LinuxNotificationCategory('network.error');

  /// A generic presence change notification
  /// that doesn't fit into any other category, such as going away or idle.
  static const LinuxNotificationCategory presence =
      LinuxNotificationCategory('presence');

  /// An offline presence change notification.
  static const LinuxNotificationCategory presenceOffile =
      LinuxNotificationCategory('presence.offline');

  /// An online presence change notification.
  static const LinuxNotificationCategory presenceOnline =
      LinuxNotificationCategory('presence.online');

  /// A generic file transfer or download notification
  /// that doesn't fit into any other category.
  static const LinuxNotificationCategory transfer =
      LinuxNotificationCategory('transfer');

  /// A file transfer or download complete notification.
  static const LinuxNotificationCategory transferComplete =
      LinuxNotificationCategory('transfer.complete');

  /// A file transfer or download error.
  static const LinuxNotificationCategory transferError =
      LinuxNotificationCategory('transfer.error');

  /// Name of category.
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationCategory && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'LinuxNotificationCategory(name: $name)';
}
