import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_example/main.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationEventListener extends StatefulWidget {
  const NavigationEventListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  _NavigationEventListenerState createState() =>
      _NavigationEventListenerState();
}

class _NavigationEventListenerState extends State<NavigationEventListener> {
  ReceivePort port = ReceivePort();

  @override
  void initState() {
    super.initState();

    if (!IsolateNameServer.registerPortWithName(port.sendPort, portName)) {
      throw Exception('Could not register SendPort');
    }

    // ignore: avoid_annotating_with_dynamic
    port.listen((dynamic data) async {
      final NotificationActionDetails action = data;
      if (action.actionId == urlLaunchActionId) {
        await launch('https://flutter.dev');
      }
      if (action.actionId == navigationActionId) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) => SecondPage(action.payload),
        ));
      }
      if (action.input?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Text input: ${action.input}'),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
