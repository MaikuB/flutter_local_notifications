import 'dart:io';

import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';

const WindowsInitializationSettings settings = WindowsInitializationSettings(
  appName: 'Test app',
  appUserModelId: 'com.test.test',
  guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
);

extension PluginUtils on FlutterLocalNotificationsWindows {
  static int id = 15;

  Future<void> showDetails(WindowsNotificationDetails details) =>
      show(id++, 'Title', 'Body', details: details);

  void testDetails(WindowsNotificationDetails details) =>
      expect(showDetails(details), completes);
}

void main() => group('Details:', () {
      FlutterLocalNotificationsWindows().enableMultithreading();
      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows();
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

      test(
          'Simple details',
          () async => plugin
            ..testDetails(const WindowsNotificationDetails())
            ..testDetails(
                const WindowsNotificationDetails(subtitle: 'Subtitle'))
            ..testDetails(const WindowsNotificationDetails(
                duration: WindowsNotificationDuration.long))
            ..testDetails(const WindowsNotificationDetails(
                scenario: WindowsNotificationScenario.reminder))
            ..testDetails(WindowsNotificationDetails(timestamp: DateTime.now()))
            ..testDetails(const WindowsNotificationDetails(
                subtitle: '{message}',
                bindings: <String, String>{'message': 'Hello, Mr. Person'})));

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
          image: File('test/icon.png').absolute,
        );
        plugin
          ..testDetails(const WindowsNotificationDetails(
              actions: <WindowsAction>[simpleAction]))
          ..testDetails(WindowsNotificationDetails(
              actions: <WindowsAction>[complexAction]))
          ..testDetails(WindowsNotificationDetails(
              actions: List<WindowsAction>.filled(5, simpleAction)));
        expect(
          plugin.showDetails(
            WindowsNotificationDetails(
              actions: List<WindowsAction>.filled(6, simpleAction),
            ),
          ),
          throwsArgumentError,
        );
      });

      test(
          'Audio',
          () => plugin
            ..testDetails(WindowsNotificationDetails(
                audio: WindowsNotificationAudio.silent()))
            ..testDetails(WindowsNotificationDetails(
                audio: WindowsNotificationAudio.preset(
                    sound: WindowsNotificationSound.call10))));

      test('Rows', () {
        const WindowsColumn emptyColumn =
            WindowsColumn(<WindowsNotificationPart>[]);
        final WindowsImage image = WindowsImage.file(
            File('test/icon.png').absolute,
            altText: 'an icon');
        const WindowsNotificationText text =
            WindowsNotificationText(text: 'Text');
        final WindowsColumn simpleColumn =
            WindowsColumn(<WindowsNotificationPart>[image, text]);
        final WindowsRow bigRow = WindowsRow(
          List<WindowsColumn>.filled(5, simpleColumn),
        );
        plugin
          ..testDetails(const WindowsNotificationDetails())
          ..testDetails(const WindowsNotificationDetails(
              rows: <WindowsRow>[WindowsRow(<WindowsColumn>[])]))
          ..testDetails(const WindowsNotificationDetails(rows: <WindowsRow>[
            WindowsRow(<WindowsColumn>[emptyColumn])
          ]))
          ..testDetails(WindowsNotificationDetails(rows: <WindowsRow>[
            WindowsRow(<WindowsColumn>[simpleColumn])
          ]))
          ..testDetails(WindowsNotificationDetails(rows: <WindowsRow>[bigRow]))
          ..testDetails(WindowsNotificationDetails(
              rows: List<WindowsRow>.filled(5, bigRow)));
      });

      test('Header', () async {
        const WindowsHeader header = WindowsHeader(
          id: 'header1',
          title: 'Header 1',
          arguments: 'args1',
          activation: WindowsHeaderActivation.foreground,
        );
        plugin
          ..testDetails(const WindowsNotificationDetails(header: header))
          ..testDetails(const WindowsNotificationDetails(header: header));
      });

      test('Images', () async {
        final WindowsImage simpleImage = WindowsImage.file(
          File('test/icon.png').absolute,
          altText: 'an icon',
        );
        final WindowsImage complexImage = WindowsImage.file(
          File('test/icon.png').absolute,
          altText: 'an icon',
          addQueryParams: true,
          crop: WindowsImageCrop.circle,
          placement: WindowsImagePlacement.appLogoOverride,
        );
        plugin
          ..testDetails(
              WindowsNotificationDetails(images: <WindowsImage>[simpleImage]))
          ..testDetails(WindowsNotificationDetails(
              images: <WindowsImage>[simpleImage, complexImage]))
          ..testDetails(
            WindowsNotificationDetails(
              images: List<WindowsImage>.filled(6, simpleImage),
            ),
          );
      });

      test('Inputs', () async {
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
        plugin
          ..testDetails(const WindowsNotificationDetails(
              inputs: <WindowsInput>[textInput]))
          ..testDetails(const WindowsNotificationDetails(
              inputs: <WindowsInput>[selection]))
          ..testDetails(
            WindowsNotificationDetails(
              inputs: List<WindowsInput>.filled(5, textInput),
            ),
          )
          ..testDetails(const WindowsNotificationDetails(
              inputs: <WindowsInput>[textInput],
              actions: <WindowsAction>[action]))
          ..testDetails(const WindowsNotificationDetails(
              inputs: <WindowsInput>[selection, textInput],
              actions: <WindowsAction>[action]));
        expect(
          plugin.showDetails(
            WindowsNotificationDetails(
              inputs: List<WindowsInput>.filled(6, textInput),
            ),
          ),
          throwsArgumentError,
        );
      });

      test('Progress', retry: 5, () async {
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
        final WindowsProgressBar dynamic = WindowsProgressBar(
          id: 'dynamic',
          status: 'Testing...',
          value: 0,
        );
        plugin
          ..testDetails(WindowsNotificationDetails(
              progressBars: <WindowsProgressBar>[simple]))
          ..testDetails(WindowsNotificationDetails(
              progressBars: <WindowsProgressBar>[complex]))
          ..testDetails(WindowsNotificationDetails(
              progressBars: <WindowsProgressBar>[simple, complex]))
          ..testDetails(
            WindowsNotificationDetails(
              progressBars: List<WindowsProgressBar>.filled(6, simple),
            ),
          );
        await plugin.show(
          201,
          null,
          null,
          details: WindowsNotificationDetails(
            progressBars: <WindowsProgressBar>[dynamic],
          ),
        );
        for (double i = 0; i <= 1.5; i += 0.05) {
          dynamic.value = i;
          final NotificationUpdateResult result = await plugin
              .updateProgressBar(notificationId: 201, progressBar: dynamic);
          expect(result, NotificationUpdateResult.success);
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
    });
