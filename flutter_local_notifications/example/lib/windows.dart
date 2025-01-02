import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'padded_button.dart';
import 'plugin.dart';

const WindowsInitializationSettings initSettings =
    WindowsInitializationSettings(
  appName: 'Flutter Local Notifications Example',
  appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
  guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
);

class _WindowsXmlBuilder extends StatefulWidget {
  @override
  _WindowsXmlBuilderState createState() => _WindowsXmlBuilderState();
}

class _WindowsXmlBuilderState extends State<_WindowsXmlBuilder> {
  final TextEditingController xmlController = TextEditingController();
  final Map<String, String> bindings = <String, String>{
    'message': 'Hello, World!'
  };

  final FlutterLocalNotificationsWindows? plugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          FlutterLocalNotificationsWindows>();

  String get xml => xmlController.text;

  bool isValid = true;

  void onPressed() {
    setState(() => isValid = plugin?.isValidXml(xml) ?? false);
    if (isValid) {
      plugin?.showRawXml(id: id++, xml: xml, bindings: bindings);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 500,
        child: ExpansionTile(
            title: const Text('Click to expand raw XML'),
            children: <Widget>[
              TextField(
                maxLines: 20,
                style: const TextStyle(fontFamily: 'RobotoMono'),
                controller: xmlController,
                onSubmitted: (_) => onPressed,
                decoration: InputDecoration(
                  hintText: 'Enter the raw xml',
                  errorText: isValid ? null : 'Invalid XML',
                  helperText: 'Bindings: {message} --> Hello, World!',
                  constraints:
                      const BoxConstraints.tightFor(width: 600, height: 480),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => xmlController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PaddedElevatedButton(
                buttonText: 'Show notification with raw XML',
                onPressed: onPressed,
              ),
            ]),
      );
}

List<Widget> examples() => <Widget>[
      const Text(
        'Windows-specific examples',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (MsixUtils.hasPackageIdentity())
        const Text('Running as an MSIX, all features are available')
      else
        const Text('Running as an EXE, some features are not available'),
      PaddedElevatedButton(
        buttonText: 'Show short and long notifications notification',
        onPressed: () async {
          await _showWindowsNotificationWithDuration();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show different scenarios',
        onPressed: () async {
          await _showWindowsNotificationWithScenarios();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications with some detail',
        onPressed: () async {
          await _showWindowsNotificationWithDetails();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications with image',
        onPressed: () async {
          await _showWindowsNotificationWithImages();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications with columns',
        onPressed: () async {
          await _showWindowsNotificationWithGroups();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications with progress bar',
        onPressed: () async {
          await _showWindowsNotificationWithProgress();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications with dynamic content',
        onPressed: () async {
          await _showWindowsNotificationWithDynamic();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notification with activation',
        onPressed: () async {
          await _showWindowsNotificationWithActivation();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notification with button styles',
        onPressed: () async {
          await _showWindowsNotificationWithButtonStyle();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Show notifications in a group',
        onPressed: () async {
          await _showWindowsNotificationWithHeader();
        },
      ),
      _WindowsXmlBuilder(),
    ];

Future<void> _showWindowsNotificationWithDuration() async {
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is a short notification',
    'This will last about 7 seconds',
    const NotificationDetails(
      windows: WindowsNotificationDetails(
          duration: WindowsNotificationDuration.short),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is a long notification',
    'This will last about 25 seconds',
    const NotificationDetails(
      windows: WindowsNotificationDetails(
          duration: WindowsNotificationDuration.long),
    ),
  );
}

Future<void> _showWindowsNotificationWithScenarios() async {
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is an alarm',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(
        scenario: WindowsNotificationScenario.alarm,
        actions: <WindowsAction>[
          WindowsAction(content: 'Button', arguments: 'button')
        ],
      ),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is an incoming call',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(
        scenario: WindowsNotificationScenario.incomingCall,
        actions: <WindowsAction>[
          WindowsAction(content: 'Button', arguments: 'button')
        ],
      ),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is a reminder',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(
          scenario: WindowsNotificationScenario.reminder,
          actions: <WindowsAction>[
            WindowsAction(content: 'Button', arguments: 'button')
          ]),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is an urgent notification',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(
          scenario: WindowsNotificationScenario.urgent,
          actions: <WindowsAction>[
            WindowsAction(content: 'Button', arguments: 'button')
          ]),
    ),
  );
}

Future<void> _showWindowsNotificationWithDetails() =>
    flutterLocalNotificationsPlugin.show(
      id++,
      'This one has more details',
      'And a different timestamp!',
      NotificationDetails(
        windows: WindowsNotificationDetails(
          subtitle: 'This is the subtitle',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
        ),
      ),
    );

Future<void> _showWindowsNotificationWithImages() =>
    flutterLocalNotificationsPlugin.show(
      id++,
      'This notification has an image',
      'You can show images from assets or the network. See the columns example as well.',
      NotificationDetails(
        windows: WindowsNotificationDetails(
          images: <WindowsImage>[
            WindowsImage(
              WindowsImage.getAssetUri('icons/4.0x/app_icon_density.png'),
              altText: 'A beautiful image',
            ),
          ],
        ),
      ),
    );

Future<void> _showWindowsNotificationWithGroups() =>
    flutterLocalNotificationsPlugin.show(
      id++,
      'This notification has many groups',
      'Each group stays together. Web images only load in MSIX builds',
      NotificationDetails(
        windows: WindowsNotificationDetails(
          subtitle: 'Caption text is fainter',
          rows: <WindowsRow>[
            WindowsRow(<WindowsColumn>[
              WindowsColumn(<WindowsNotificationPart>[
                WindowsImage(
                  WindowsImage.getAssetUri('icons/coworker.png'),
                  altText: 'A local image',
                ),
                const WindowsNotificationText(
                  text: 'A local image',
                  isCaption: true,
                ),
              ]),
              WindowsColumn(<WindowsNotificationPart>[
                WindowsImage(
                  Uri.parse('https://picsum.photos/100'),
                  altText: 'A web image',
                ),
                const WindowsNotificationText(text: 'A web image'),
              ]),
            ]),
          ],
        ),
      ),
    );

Future<void> _showWindowsNotificationWithProgress() async {
  final WindowsProgressBar fastProgress = WindowsProgressBar(
      id: 'fast-progress', status: 'Updating quickly...', value: 0);
  final WindowsProgressBar slowProgress = WindowsProgressBar(
      id: 'slow-progress',
      status: 'Updating slowly...',
      value: 0,
      label: '0 / 10');
  final int notificationId = id++;
  final FlutterLocalNotificationsWindows? windows =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          FlutterLocalNotificationsWindows>();
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'This notification has progress bars',
    'You can have precise or indeterminate',
    NotificationDetails(
      windows: WindowsNotificationDetails(
        progressBars: <WindowsProgressBar>[
          WindowsProgressBar(
            id: 'indeterminate',
            title: 'This has indeterminate progress',
            status: 'Downloading...',
            value: null,
          ),
          WindowsProgressBar(
            id: 'continuous',
            title: 'This has continuous progress',
            status: 'Uploading...',
            value: 0.75,
          ),
          WindowsProgressBar(
              id: 'discrete',
              title: 'This has discrete progress',
              status: 'Syncing...',
              value: 0.75,
              label: '9/12 complete'),
          fastProgress,
          slowProgress,
        ],
      ),
    ),
  );

  int count = 0;
  Timer.periodic(const Duration(milliseconds: 100), (Timer timer) async {
    fastProgress.value = fastProgress.value! + 0.05;
    slowProgress.value = count++ / 50;
    fastProgress.value = fastProgress.value!.clamp(0, 1);
    slowProgress.value = slowProgress.value!.clamp(0, 1);
    if (fastProgress.value == 1 && slowProgress.value == 1) {
      return timer.cancel();
    }
    count = count.clamp(0, 50);
    slowProgress.label = '$count / 50';
    await windows?.updateProgressBar(
        notificationId: notificationId, progressBar: fastProgress);
    await windows?.updateProgressBar(
        notificationId: notificationId, progressBar: slowProgress);
  });
}

Future<void> _showWindowsNotificationWithDynamic() async {
  final DateTime start = DateTime.now();
  final int notificationId = id++;
  final FlutterLocalNotificationsWindows? windows =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          FlutterLocalNotificationsWindows>();
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Dynamic content',
    'This notification will be updated from Dart code',
    const NotificationDetails(
      windows: WindowsNotificationDetails(
        subtitle: '{stopwatch}',
      ),
    ),
  );
  Map<String, String> getBindings() => <String, String>{
        'stopwatch':
            'Elapsed time: ${DateTime.now().difference(start).inSeconds} seconds',
      };
  await windows?.updateBindings(id: notificationId, bindings: getBindings());
  Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
    if (timer.tick > 10) {
      timer.cancel();
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      return;
    }
    await windows?.updateBindings(id: notificationId, bindings: getBindings());
  });
}

Future<void> _showWindowsNotificationWithActivation() =>
    flutterLocalNotificationsPlugin.show(
      id++,
      'These buttons do different things',
      'Click on each one!',
      const NotificationDetails(
        windows: WindowsNotificationDetails(
          actions: <WindowsAction>[
            WindowsAction(
              content: 'Loading',
              arguments: 'loading',
              activationBehavior: WindowsNotificationBehavior.pendingUpdate,
            ),
            WindowsAction(
              content: 'Google',
              arguments: 'https://google.com',
              activationType: WindowsActivationType.protocol,
              activationBehavior: WindowsNotificationBehavior.pendingUpdate,
            ),
          ],
        ),
      ),
    );

Future<void> _showWindowsNotificationWithButtonStyle() =>
    flutterLocalNotificationsPlugin.show(
      id++,
      'Incoming call',
      'Your best friend',
      const NotificationDetails(
        windows: WindowsNotificationDetails(
          actions: <WindowsAction>[
            WindowsAction(
              content: 'Accept',
              arguments: 'accept',
              buttonStyle: WindowsButtonStyle.success,
            ),
            WindowsAction(
              content: 'Reject',
              arguments: 'reject',
              buttonStyle: WindowsButtonStyle.critical,
            ),
          ],
        ),
      ),
    );

Future<void> _showWindowsNotificationWithHeader() async {
  const WindowsHeader header = WindowsHeader(
    id: 'header',
    title: 'Cool notifications',
    arguments: 'header-clicked',
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is the first notification',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(header: header),
    ),
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    'This is the second notification',
    null,
    const NotificationDetails(
      windows: WindowsNotificationDetails(header: header),
    ),
  );
}
