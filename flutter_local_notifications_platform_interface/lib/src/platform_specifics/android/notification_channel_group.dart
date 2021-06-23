/// A group of related Android notification channels.
class AndroidNotificationChannelGroup {
  /// Constructs an instance of [AndroidNotificationChannelGroup].
  const AndroidNotificationChannelGroup(
    this.id,
    this.name, {
    this.description,
  });

  /// The id of this group.
  final String id;

  /// The name of this group.
  final String name;

  /// The description of this group.
  ///
  /// Only applicable to Android 9.0 or newer.
  final String? description;
}
