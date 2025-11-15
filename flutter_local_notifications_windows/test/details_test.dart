import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:flutter_local_notifications_windows/src/details/notification_to_xml.dart';
import 'package:flutter_local_notifications_windows/src/ffi/mock.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
  appName: 'Test app',
  appUserModelId: 'com.test.test',
  guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
);

extension on WindowsNotificationDetails {
  String toXml() => notificationToXml(
        title: 'title',
        body: 'body',
        payload: 'payload',
        details: this,
      );

  void check(List<String> keywords) {
    final String xml = toXml();
    expect(
      () => XmlDocument.parse(toXml()),
      returnsNormally,
      reason: 'Was not a valid XML doc',
    );
    for (final String keyword in keywords) {
      expect(xml.contains(keyword), isTrue,
          reason: 'Could not find $keyword in $xml');
    }
  }

  void count(String keyword, int x) {
    final String xml = toXml();
    expect(
      () => XmlDocument.parse(toXml()),
      returnsNormally,
      reason: 'Was not a valid XML doc',
    );
    expect(
      keyword.allMatches(xml).length,
      x,
      reason: 'Could not find $keyword $x times in $xml',
    );
  }
}

void main() => group('Details:', () {
      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows.withBindings(MockBindings());
      setUpAll(() => plugin.initialize(settings));
      tearDownAll(() async {
        await plugin.cancelAll();
        plugin.dispose();
      });

      test('No details', () async {
        expect(plugin.show(100, null, null), completes);
        expect(plugin.show(101, 'Title', null), completes);
        expect(plugin.show(102, null, 'Body'), completes);
        expect(plugin.show(103, 'Title', 'Body'), completes);
        expect(plugin.show(-1, 'Negative ID', 'Body'), completes);
      });

      test('Simple details', () {
        const WindowsNotificationDetails().check(<String>[]);
        const WindowsNotificationDetails(subtitle: 'Subtitle')
            .check(<String>['Subtitle']);
        const WindowsNotificationDetails(
          duration: WindowsNotificationDuration.long,
        ).check(<String>['long']);
        const WindowsNotificationDetails(
          scenario: WindowsNotificationScenario.reminder,
        ).check(<String>['reminder']);
        final DateTime now = DateTime.now();
        WindowsNotificationDetails(timestamp: now)
            .check(<String>[now.toIso8601String().split('.').first]);
        const WindowsNotificationDetails(
          subtitle: '{message}',
          bindings: <String, String>{'message': 'Hello, Mr. Person'},
        ).check(<String>['binding', 'message']);
      });

      test('Actions', () {
        const WindowsAction simpleAction =
            WindowsAction(content: 'Press me', arguments: '123');
        final WindowsAction complexAction = WindowsAction(
          content: 'content',
          arguments: 'args',
          activationBehavior: WindowsNotificationBehavior.pendingUpdate,
          buttonStyle: WindowsButtonStyle.success,
          inputId: 'input-id',
          tooltip: 'tooltip',
          imageUri: WindowsImage.getAssetUri('test/icon.png'),
        );
        const WindowsNotificationDetails(
          actions: <WindowsAction>[simpleAction],
        ).check(<String>['Press me', '123']);
        WindowsNotificationDetails(
          actions: <WindowsAction>[complexAction],
        ).check(<String>[
          'content',
          'args',
          'pendingUpdate',
          'Success',
          'input-id',
          'tooltip',
          'test/icon.png',
        ]);
        WindowsNotificationDetails(
          actions: List<WindowsAction>.filled(5, simpleAction),
        );
        expect(
          () => notificationToXml(
              details: WindowsNotificationDetails(
            actions: List<WindowsAction>.filled(6, simpleAction),
          )),
          throwsArgumentError,
        );
      });

      test('Audio', () {
        WindowsNotificationDetails(
          audio: WindowsNotificationAudio.silent(),
        ).check(<String>['silent']);
        WindowsNotificationDetails(
          audio: WindowsNotificationAudio.preset(
              sound: WindowsNotificationSound.call10),
        ).check(<String>['Call10']);
      });

      test('Rows', () {
        const WindowsColumn emptyColumn =
            WindowsColumn(<WindowsNotificationPart>[]);
        final WindowsImage image = WindowsImage(
          WindowsImage.getAssetUri('test/icon.png'),
          altText: 'an icon',
        );
        const WindowsNotificationText text =
            WindowsNotificationText(text: 'Text');
        final WindowsColumn simpleColumn =
            WindowsColumn(<WindowsNotificationPart>[image, text]);
        final WindowsRow bigRow = WindowsRow(
          List<WindowsColumn>.filled(5, simpleColumn),
        );
        const WindowsNotificationDetails(
          rows: <WindowsRow>[WindowsRow(<WindowsColumn>[])],
        ).check(<String>['group']);
        const WindowsNotificationDetails(
          rows: <WindowsRow>[
            WindowsRow(<WindowsColumn>[emptyColumn])
          ],
        ).check(<String>['group', 'subgroup']);
        WindowsNotificationDetails(
          rows: <WindowsRow>[
            WindowsRow(<WindowsColumn>[simpleColumn])
          ],
        ).check(
            <String>['group', 'subgroup', 'test/icon.png', 'an icon', 'Text']);
        WindowsNotificationDetails(
          rows: <WindowsRow>[bigRow],
        ).count('<subgroup', 5);
        WindowsNotificationDetails(
          rows: List<WindowsRow>.filled(5, bigRow),
        ).count('<subgroup', 25);
      });

      test('Header', () async {
        const WindowsHeader header = WindowsHeader(
          id: 'header1',
          title: 'Header 1',
          arguments: 'args1',
          activation: WindowsHeaderActivation.foreground,
        );

        const WindowsNotificationDetails(header: header)
            .check(<String>['header1', 'Header 1', 'args1', 'foreground']);
      });

      test('Images', () {
        final WindowsImage simpleImage = WindowsImage(
          WindowsImage.getAssetUri('asset.png'),
          altText: 'an icon',
        );
        final WindowsImage complexImage = WindowsImage(
          Uri.parse('https://picsum.photos/500'),
          altText: 'an icon2',
          addQueryParams: true,
          crop: WindowsImageCrop.circle,
          placement: WindowsImagePlacement.appLogoOverride,
        );

        WindowsNotificationDetails(images: <WindowsImage>[simpleImage])
            .check(<String>['asset.png', 'an icon']);
        WindowsNotificationDetails(
          images: <WindowsImage>[simpleImage, complexImage],
        ).check(
            <String>['asset.png', 'an icon', 'picsum.photos/500', 'an icon2']);

        WindowsNotificationDetails(
          images: List<WindowsImage>.filled(6, simpleImage),
        ).count('asset.png', 6);
      });

      test('Inputs', () {
        const WindowsTextInput textInput = WindowsTextInput(
          id: 'input',
          placeHolderContent: 'Text hint',
          title: 'Text title',
        );
        const WindowsSelectionInput selection = WindowsSelectionInput(
          id: 'input',
          items: <WindowsSelection>[
            WindowsSelection(id: 'item1', content: 'Item 1'),
            WindowsSelection(id: 'item2', content: 'Item 2'),
            WindowsSelection(id: 'item3', content: 'Item 3'),
          ],
        );
        const WindowsAction action = WindowsAction(
          content: 'Submit',
          arguments: 'submit',
          inputId: 'input',
        );
        const WindowsNotificationDetails(
          inputs: <WindowsInput>[textInput],
        ).check(<String>['input', 'Text hint', 'Text title']);
        const WindowsNotificationDetails(
          inputs: <WindowsInput>[selection],
        ).check(<String>['input', 'item1', 'item2', 'item3']);

        WindowsNotificationDetails(
          inputs: List<WindowsInput>.filled(5, textInput),
        ).count('Text hint', 5);
        const WindowsNotificationDetails(
          inputs: <WindowsInput>[textInput],
          actions: <WindowsAction>[action],
        ).check(<String>['Text hint', 'Submit']);
        const WindowsNotificationDetails(
          inputs: <WindowsInput>[selection, textInput],
          actions: <WindowsAction>[action],
        ).check(<String>['Text hint', 'item1', 'Submit']);
        expect(
          () => notificationToXml(
            details: WindowsNotificationDetails(
              inputs: List<WindowsInput>.filled(6, textInput),
            ),
          ),
          throwsArgumentError,
        );
      });

      test('Progress', () {
        final WindowsProgressBar simple = WindowsProgressBar(
          id: 'simple',
          status: 'Testing...',
          value: 0.25,
        );
        final WindowsProgressBar complex = WindowsProgressBar(
          id: 'complex',
          status: 'Testing...',
          value: 0.75,
          label: 'Progress label',
          title: 'Progress title',
        );
        WindowsNotificationDetails(progressBars: <WindowsProgressBar>[simple])
            .check(<String>['simple', 'Testing', 'simple-progressValue']);
        WindowsNotificationDetails(progressBars: <WindowsProgressBar>[complex])
            .check(<String>[
          'complex',
          'Testing...',
          'complex-progressValue',
          'complex-progressString',
          'Progress title'
        ]);
        WindowsNotificationDetails(
          progressBars: <WindowsProgressBar>[simple, complex],
        ).check(<String>['simple', 'complex']);
        WindowsNotificationDetails(
          progressBars: List<WindowsProgressBar>.filled(6, simple),
        ).count('simple', 6);
      });
    });
