import 'style_information.dart';

/// The default Android notification style.
class DefaultStyleInformation implements StyleInformation {
  /// Constructs an instance of [DefaultStyleInformation].
  const DefaultStyleInformation(
    this.htmlFormatContent,
    this.htmlFormatTitle,
  );

  /// Specifies if formatting should be applied to the content through HTML
  /// markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML
  /// markup.
  final bool htmlFormatTitle;
}
