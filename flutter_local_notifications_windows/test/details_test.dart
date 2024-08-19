import "dart:io";

import "package:test/test.dart";
import "package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart";

const settings = WindowsInitializationSettings(appName: "Test app", appUserModelId: "com.test.test", guid: "a8c22b55-049e-422f-b30f-863694de08c8");

extension PluginUtils on FlutterLocalNotificationsWindows {
  static int id = 15;

  Future<void> showDetails(WindowsNotificationDetails details) =>
    show(id++, "Title", "Body", details: details);

  void testDetails(WindowsNotificationDetails details) =>
    expect(showDetails(details), completes);
}

void main() => group("Details:", () {
  final plugin = FlutterLocalNotificationsWindows();
  setUpAll(() => plugin.initialize(settings));
  tearDownAll(() async { await plugin.cancelAll(); plugin.dispose(); });

  test("No details", () async {
    expect(plugin.show(100, null, null), completes);
    expect(plugin.show(101, "Title", null), completes);
    expect(plugin.show(102, null, "Body"), completes);
    expect(plugin.show(103, "Title", "Body"), completes);
    expect(plugin.show(-1, "Negative ID", "Body"), completes);
  });

  test("Simple details", () async {
    plugin.testDetails(const WindowsNotificationDetails());
    plugin.testDetails(const WindowsNotificationDetails(subtitle: "Subtitle"));
    plugin.testDetails(const WindowsNotificationDetails(duration: WindowsNotificationDuration.long));
    plugin.testDetails(const WindowsNotificationDetails(scenario: WindowsNotificationScenario.reminder));
    plugin.testDetails(WindowsNotificationDetails(timestamp: DateTime.now()));
    plugin.testDetails(const WindowsNotificationDetails(subtitle: "{message}", bindings: {"message": "Hello, Mr. Person"}));
  });

  test("Actions", () {
    const simpleAction = WindowsAction(content: "Press me", arguments: "123");
    final complexAction = WindowsAction(
      content: "content",
      arguments: "args",
      activationBehavior: WindowsNotificationBehavior.pendingUpdate,
      buttonStyle: WindowsButtonStyle.success,
      inputId: "input-id",
      tooltip: "tooltip",
      image: File("test/icon.png").absolute,
    );
    plugin.testDetails(const WindowsNotificationDetails(actions: [simpleAction]));
    plugin.testDetails(WindowsNotificationDetails(actions: [complexAction]));
    plugin.testDetails(WindowsNotificationDetails(actions: List.filled(5, simpleAction)));
    expect(plugin.showDetails(WindowsNotificationDetails(actions: List.filled(6, simpleAction))), throwsArgumentError);
  });

  test("Audio", () {
    plugin.testDetails(WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()));
    plugin.testDetails(WindowsNotificationDetails(audio: WindowsNotificationAudio.preset(sound: WindowsNotificationSound.call10)));
  });

  test("Rows", () {
    const emptyColumn = WindowsColumn([]);
    final image = WindowsImage.file(File("test/icon.png").absolute, altText: "an icon");
    const text = WindowsNotificationText(text: "Text");
    final simpleColumn = WindowsColumn([image, text]);
    final bigRow = WindowsRow(List.filled(5, simpleColumn));
    plugin.testDetails(const WindowsNotificationDetails());
    plugin.testDetails(const WindowsNotificationDetails(groups: [WindowsRow([])]));
    plugin.testDetails(const WindowsNotificationDetails(groups: [WindowsRow([emptyColumn])]));
    plugin.testDetails(WindowsNotificationDetails(groups: [WindowsRow([simpleColumn])]));
    plugin.testDetails(WindowsNotificationDetails(groups: [bigRow]));
    plugin.testDetails(WindowsNotificationDetails(groups: List.filled(5, bigRow)));
  });

  test("Header", () async {
    const header =  WindowsHeader(id: "header1", title: "Header 1", arguments: "args1", activation: WindowsHeaderActivation.foreground);
    plugin.testDetails(const WindowsNotificationDetails(header: header));
    plugin.testDetails(const WindowsNotificationDetails(header: header));
  });

  test("Images", () async {
    final simpleImage = WindowsImage.file(File("test/icon.png").absolute, altText: "an icon");
    final complexImage = WindowsImage.file(
      File("test/icon.png").absolute,
      altText: "an icon",
      addQueryParams: true,
      crop: WindowsImageCrop.circle,
      placement: WindowsImagePlacement.appLogoOverride,
    );
    plugin.testDetails(WindowsNotificationDetails(images: [simpleImage]));
    plugin.testDetails(WindowsNotificationDetails(images: [simpleImage, complexImage]));
    plugin.testDetails(WindowsNotificationDetails(images: List.filled(6, simpleImage)));
  });

  test("Inputs", () async {
    const textInput = WindowsTextInput(id: "input", placeHolderContent: "Text hint", title: "Text title");
    const selection = WindowsSelectionInput(id: "input", items: [
      WindowsSelection(id: "item1", content: "Item 1"),
      WindowsSelection(id: "item2", content: "Item 2"),
      WindowsSelection(id: "item3", content: "Item 3"),
    ],);
    const action = WindowsAction(content: "Submit", arguments: "submit", inputId: "input");
    plugin.testDetails(const WindowsNotificationDetails(inputs: [textInput]));
    plugin.testDetails(const WindowsNotificationDetails(inputs: [selection]));
    plugin.testDetails(WindowsNotificationDetails(inputs: List.filled(5, textInput)));
    plugin.testDetails(const WindowsNotificationDetails(inputs: [textInput], actions: [action]));
    expect(plugin.showDetails(WindowsNotificationDetails(inputs: List.filled(6, textInput))), throwsArgumentError);
    plugin.testDetails(const WindowsNotificationDetails(inputs: [selection, textInput], actions: [action]));
  });

  test("Progress", retry: 5, () async {
    final simple = WindowsProgressBar(id: "simple", status: "Testing...", value: 0.25);
    final complex = WindowsProgressBar(id: "complex", status: "Testing...", value: 0.75, label: "Progress label", title: "Progress title");
    final dynamic = WindowsProgressBar(id: "dynamic", status: "Testing...", value: 0);
    plugin.testDetails(WindowsNotificationDetails(progressBars: [simple]));
    plugin.testDetails(WindowsNotificationDetails(progressBars: [complex]));
    plugin.testDetails(WindowsNotificationDetails(progressBars: [simple, complex]));
    plugin.testDetails(WindowsNotificationDetails(progressBars: List.filled(6, simple)));
    await plugin.show(201, null, null, details: WindowsNotificationDetails(progressBars: [dynamic]));
    for (var i = 0.0; i <= 1.5; i += 0.05) {
      dynamic.value = i;
      final result = await plugin.updateProgressBar(notificationId: 201, progressBar: dynamic);
      expect(result, NotificationUpdateResult.success);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });
});
