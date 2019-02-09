part of flutter_local_notifications;

class Person {
  final bool bot;
  final String icon;
  final BitmapSource iconBitmapSource;
  final bool important;
  final String key;
  final String name;
  final String uri;

  Person(
      {this.bot,
      this.icon,
      this.iconBitmapSource,
      this.important,
      this.key,
      this.name,
      this.uri});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bot': bot,
      'icon': icon,
      'iconBitmapSource': iconBitmapSource?.index,
      'important': important,
      'key': key,
      'name': name,
      'uri': uri
    };
  }
}
