
/// Configures notification details specific to Web
class WebNotificationDetails {


///  "//": "Visual Options",
///  "body": "<String>",
///  "icon": "<URL String>",
///  "image": "<URL String>",
///  "badge": "<URL String>",
///  "vibrate": "<Array of Integers>",
///  "sound": "<URL String>",
///  "dir": "<String of 'auto' | 'ltr' | 'rtl'>",
///
///  "///": "Behavioural Options",
///  "tag": "<String>",
///  "data": "<Anything>",
///  "requireInteraction": "<boolean>",
///  "renotify": "<Boolean>",
///  "silent": "<Boolean>",
///
///  "///": "Both Visual & Behavioural Options",
///  "actions": "<Array of Strings>",
///
///  "///": "Information Option. No visual affect.",
///  "timestamp": "<Long>"
  WebNotificationDetails({
    this.body,
    this.icon,
    this.image,
    this.badge,
    this.vibrate,
    this.sound,
    this.dir,
    this.tag,
    this.data,
    this.requireInteraction,
    this.renotify,
    this.silent,
    this.actions,
    this.timestamp});

//  "//": "Visual Options",
  String? body;

  String? icon;

  String? image;

  String? badge;

  List<int>? vibrate;

  String? sound;

  String? dir;

//  "//": "Behavioural Options",
  String? tag;

  dynamic? data;

  bool? requireInteraction;

  bool? renotify;

  bool? silent;

//  "//": "Both Visual & Behavioural Options",
  List<String>? actions;

//  "//": "Information Option. No visual affect.",
  int? timestamp;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['body'] = this.body;
    data['icon'] = this.icon;
    data['image'] = this.image;
    data['badge'] = this.badge;
    data['vibrate'] = this.vibrate;
    data['sound'] = this.sound;
    data['dir'] = this.dir;
    data['tag'] = this.tag;
    data['data'] = this.data;
    data['requireInteraction'] = this.requireInteraction;
    data['renotify'] = this.renotify;
    data['silent'] = this.silent;
    data['actions'] = this.actions;
    data['timestamp'] = this.timestamp;
    return data;
  }

}