import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
    appName: 'test',
    appUserModelId: 'com.test.test',
    guid: 'a8c22b55-049e-422f-b30f-863694de08c8');
const String emptyXml = '';
const String invalidXml = 'Blah blah blah';
const String notWindowsXml = '<text>Hi<text>';
const String unmatchedXml = '<text>Hi';
const String validXml = '''
<toast>

  <visual>
    <binding template="ToastGeneric">
      <text>Hello World</text>
      <text>This is a simple toast message</text>
    </binding>
  </visual>

</toast>
''';

const String complexXml = '''
<toast launch="action=viewEvent&amp;eventId=63851">

  <visual>
    <binding template="ToastGeneric">
      <text>Surface Launch Party</text>
      <text>Studio S / Ballroom</text>
      <text>4:00 PM, 10/26/2015</text>
    </binding>
  </visual>

  <actions>

    <input id="status" type="selection" defaultInput="yes">
      <selection id="yes" content="Going"/>
      <selection id="maybe" content="Maybe"/>
      <selection id="no" content="Decline"/>
    </input>

    <action
      activationType="background"
      arguments="action=rsvpEvent&amp;eventId=63851"
      content="RSVP"/>

    <action
      activationType="system"
      arguments="dismiss"
      content=""/>

  </actions>

</toast>
''';

void main() => group('XML', () {
      FlutterLocalNotificationsWindows().enableMultithreading();

      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows();
      setUpAll(() => plugin.initialize(settings));
      tearDownAll(() async {
        await plugin.cancelAll();
        plugin.dispose();
      });

      test('catches invalid XML', () async {
        expect(plugin.showRawXml(id: 0, xml: emptyXml), throwsArgumentError);
        expect(plugin.showRawXml(id: 1, xml: invalidXml), throwsArgumentError);
        expect(
            plugin.showRawXml(id: 2, xml: notWindowsXml), throwsArgumentError);
        expect(
            plugin.showRawXml(id: 3, xml: unmatchedXml), throwsArgumentError);
        expect(plugin.showRawXml(id: 4, xml: validXml), completes);
        expect(plugin.showRawXml(id: 5, xml: complexXml), completes);
      });
    });
