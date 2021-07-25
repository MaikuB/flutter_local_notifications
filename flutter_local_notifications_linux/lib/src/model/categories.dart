import 'package:flutter/foundation.dart';

/// Categories of notifications.
@immutable
class LinuxNotificationCategory {
  /// Constructs an instance of [LinuxNotificationCategory]
  /// with a given [name] of category.
  const LinuxNotificationCategory(this.name);

  /// A generic device-related notification
  /// that doesn't fit into any other category.
  factory LinuxNotificationCategory.device() =>
      const LinuxNotificationCategory('device');

  /// A device, such as a USB device, was added to the system.
  factory LinuxNotificationCategory.deviceAdded() =>
      const LinuxNotificationCategory('device.added');

  /// A device had some kind of error.
  factory LinuxNotificationCategory.deviceError() =>
      const LinuxNotificationCategory('device.error');

  /// A device, such as a USB device, was removed from the system.
  factory LinuxNotificationCategory.deviceRemoved() =>
      const LinuxNotificationCategory('device.removed');

  /// A generic e-mail-related notification
  /// that doesn't fit into any other category.
  factory LinuxNotificationCategory.email() =>
      const LinuxNotificationCategory('email');

  /// A new e-mail notification.
  factory LinuxNotificationCategory.emailArrived() =>
      const LinuxNotificationCategory('email.arrived');

  /// A notification stating that an e-mail has bounced.
  factory LinuxNotificationCategory.emailBounced() =>
      const LinuxNotificationCategory('email.bounced');

  /// A generic instant message-related notification
  /// that doesn't fit into any other
  factory LinuxNotificationCategory.im() =>
      const LinuxNotificationCategory('im');

  /// An instant message error notification.
  factory LinuxNotificationCategory.imError() =>
      const LinuxNotificationCategory('im.error');

  /// A received instant message notification.
  factory LinuxNotificationCategory.imReceived() =>
      const LinuxNotificationCategory('im.received');

  /// A generic network notification that
  /// doesn't fit into any other category.
  factory LinuxNotificationCategory.network() =>
      const LinuxNotificationCategory('network');

  /// A network connection notification,
  /// such as successful sign-on to a network service.
  /// This should not be confused with
  /// [LinuxNotificationCategory.deviceAdded] for new network devices.
  factory LinuxNotificationCategory.networkConnected() =>
      const LinuxNotificationCategory('network.connected');

  /// A network disconnected notification.
  /// This should not be confused with [LinuxNotificationCategory.deviceRemoved]
  /// for disconnected network devices.
  factory LinuxNotificationCategory.networkDisconnected() =>
      const LinuxNotificationCategory('network.disconnected');

  /// A network-related or connection-related error.
  factory LinuxNotificationCategory.networkError() =>
      const LinuxNotificationCategory('network.error');

  /// A generic presence change notification
  /// that doesn't fit into any other category, such as going away or idle.
  factory LinuxNotificationCategory.presence() =>
      const LinuxNotificationCategory('presence');

  /// An offline presence change notification.
  factory LinuxNotificationCategory.presenceOffile() =>
      const LinuxNotificationCategory('presence.offline');

  /// An online presence change notification.
  factory LinuxNotificationCategory.presenceOnline() =>
      const LinuxNotificationCategory('presence.online');

  /// A generic file transfer or download notification
  /// that doesn't fit into any other category.
  factory LinuxNotificationCategory.transfer() =>
      const LinuxNotificationCategory('transfer');

  /// A file transfer or download complete notification.
  factory LinuxNotificationCategory.transferComplete() =>
      const LinuxNotificationCategory('transfer.complete');

  /// A file transfer or download error.
  factory LinuxNotificationCategory.transferError() =>
      const LinuxNotificationCategory('transfer.error');

  /// Name of category.
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxNotificationCategory &&
      other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'LinuxNotificationCategory(name: $name)';
}
