import 'default_style_information.dart';

/// Used to pass the content for an Android notification displayed using the inbox style.
class InboxStyleInformation extends DefaultStyleInformation {
  const InboxStyleInformation(
    this.lines, {
    this.htmlFormatLines = false,
    this.contentTitle,
    this.htmlFormatContentTitle = false,
    this.summaryText,
    this.htmlFormatSummaryText = false,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  /// Overrides ContentTitle in the big form of the template.
  final String contentTitle;

  /// Set the first line of text after the detail section in the big form of the template.
  final String summaryText;

  /// The lines that form part of the digest section for inbox-style notifications.
  final List<String> lines;

  /// Specifies if the lines should have formatting applied through HTML markup.
  final bool htmlFormatLines;

  /// Specifies if the overridden ContentTitle should have formatting applied through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  /// Creates a [Map] object that describes the [InboxStyleInformation] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll(<String, dynamic>{
        'contentTitle': contentTitle,
        'htmlFormatContentTitle': htmlFormatContentTitle,
        'summaryText': summaryText,
        'htmlFormatSummaryText': htmlFormatSummaryText,
        'lines': lines ?? List<String>(),
        'htmlFormatLines': htmlFormatLines
      });
  }
}
