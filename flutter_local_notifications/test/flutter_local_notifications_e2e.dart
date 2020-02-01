import 'package:e2e/e2e.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  setUp(() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  });
  testWidgets('can initialise', (WidgetTester tester) async {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    final initialised = await flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    expect(initialised, isTrue);
  });
}
