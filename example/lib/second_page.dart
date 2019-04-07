import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SecondScreen extends StatefulWidget {
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen with payload: " + _payload),
      ),
      body: Column(children: [
        RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
        RaisedButton(
          onPressed: () async {
            var plugin = NotificationProvider.of(context);
            var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                'your channel id',
                'your channel name',
                'your channel description',
                importance: Importance.Max,
                priority: Priority.High);
            var iOSPlatformChannelSpecifics = IOSNotificationDetails();
            var platformChannelSpecifics = NotificationDetails(
                androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            await plugin.show(0, 'Other page',
                'insied second page', platformChannelSpecifics);
          },
          child: Text('Other notification'),
        ),
      ]),
    );
  }
}
