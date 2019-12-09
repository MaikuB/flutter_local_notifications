import 'default_style_information.dart';

class MediaStyleInformation extends DefaultStyleInformation {
  /// Request up to 3 actions (by index in the order of addition) to be shown in the compact notification view.
  /// N.B. If you set this when you don't have set actions, the notification may not appear
  final List<int> showActionsInCompactView;

  MediaStyleInformation({
    this.showActionsInCompactView,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  Map<String, dynamic> toMap() {
    var styleJson = super.toMap();

    var mediaStyleJson = <String, dynamic>{
      'showActionsInCompactView': showActionsInCompactView,
    };
    styleJson.addAll(mediaStyleJson);
    return styleJson;
  }
}
