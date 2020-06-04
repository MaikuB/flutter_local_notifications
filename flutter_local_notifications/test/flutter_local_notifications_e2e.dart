import 'package:e2e/e2e.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  setUp(() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  });
  // ignore: always_specify_types
  testWidgets('can initialise', (tester) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    final bool initialised = await flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    expect(initialised, isTrue);
  });
}
