/// The type of a [WindowsInput].
enum WindowsInputType {
  /// A text input.
  text,

  /// A multiple choice input.
  selection,
}

/// A text or multiple choice input element in a Windows notification.
sealed class WindowsInput {
  /// Creates an input field in a notification.
  const WindowsInput({
    required this.id,
    required this.type,
    this.title,
  });

  /// A unique ID for this input.
  ///
  /// Can be used by buttons to be placed next to this input.
  final String id;

  /// The type of this input.
  final WindowsInputType type;

  /// The title of this input.
  final String? title;
}

/// A text input.
class WindowsTextInput extends WindowsInput {
  /// Creates an input field in a notification.
  const WindowsTextInput({
    required super.id,
    this.placeHolderContent,
    super.title,
  }) : super(type: WindowsInputType.text);

  /// A placeholder shown before the user enters input, like a hint text.
  final String? placeHolderContent;
}

/// A multiple choice input.
class WindowsSelectionInput extends WindowsInput {
  /// Creates a selection input.
  const WindowsSelectionInput({
    required super.id,
    required this.items,
    this.defaultItem,
    super.title,
  }) : super(type: WindowsInputType.selection);

  /// The items that can be selected.
  final List<WindowsSelection> items;

  /// The default item that is selected.
  final String? defaultItem;
}

/// An option that can be selected by a [WindowsSelectionInput].
class WindowsSelection {
  /// Creates a selectable choice.
  const WindowsSelection({
    required this.id,
    required this.content,
  });

  /// A unique ID for this item.
  final String id;

  /// The content of this item in the UI.
  final String content;
}
