part of flutter_local_notifications;

/// The default Android notification style
class DefaultStyleInformation extends StyleInformation {
  /// Specifies if formatting should be applied to the content through HTML markup
  bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML markup
  bool htmlFormatTitle;

  DefaultStyleInformation(this.htmlFormatContent, this.htmlFormatTitle)
      : super();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'htmlFormatContent': htmlFormatContent,
      'htmlFormatTitle': htmlFormatTitle
    };
  }
}
