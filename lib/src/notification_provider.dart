import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends InheritedWidget {
  /// The [FlutterLocalNotificationsPlugin] which is to be made available throughout the subtree
  final FlutterLocalNotificationsPlugin service;

  /// The [Widget] and its descendants which will have access to the [FlutterLocalNotificationsPlugin].
  final Widget child;

  NotificationProvider({
    Key key,
    @required this.service,
    this.child,
  })  : assert(service != null),
        super(key: key);

  /// Method that allows widgets to access the bloc as long as their `BuildContext`
  /// contains a `NotificationProvider` instance.
  static FlutterLocalNotificationsPlugin of(BuildContext context) {

    final NotificationProvider provider = context
        .ancestorInheritedElementForWidgetOfExactType(NotificationProvider)
        ?.widget as NotificationProvider;

    if (provider == null) {
      throw FlutterError(
        """
        NotificationProvider.of() called with a context that does not contain a NotificationProvider.
        No ancestor could be found starting from the context that was passed to NotificationProvider.of().
        This can happen if the context you use comes from a widget above the NotificationProvider.
        This can also happen.
        The context used was: $context
        """,
      );
    }
    return provider?.service;
  }

  @override
  bool updateShouldNotify(NotificationProvider oldWidget) => false;
}
