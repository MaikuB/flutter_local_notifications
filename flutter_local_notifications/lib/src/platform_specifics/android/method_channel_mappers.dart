import 'dart:ui';
import 'enums.dart';
import 'initialization_settings.dart';
import 'message.dart';
import 'notification_channel.dart';
import 'notification_channel_group.dart';
import 'notification_details.dart';
import 'notification_sound.dart';
import 'person.dart';
import 'styles/big_picture_style_information.dart';
import 'styles/big_text_style_information.dart';
import 'styles/default_style_information.dart';
import 'styles/inbox_style_information.dart';
import 'styles/media_style_information.dart';
import 'styles/messaging_style_information.dart';

// ignore_for_file: avoid_as, public_member_api_docs
extension AndroidInitializationSettingsMapper on AndroidInitializationSettings {
  Map<String, Object> toMap() => <String, Object>{'defaultIcon': defaultIcon};
}

extension MessageMapper on Message {
  Map<String, Object?> toMap() => <String, Object?>{
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'person': person?.toMap(),
        'dataMimeType': dataMimeType,
        'dataUri': dataUri
      };
}

extension AndroidNotificationChannelGroupMapper
    on AndroidNotificationChannelGroup {
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'name': name,
        'description': description,
      };
}

extension AndroidNotificationChannelMapper on AndroidNotificationChannel {
  Map<String, Object?> toMap() {
    final Color? color = ledColor;

    // Convert normalized channels (0.0–1.0) to 8-bit ints (0–255).
    final int? alpha8 =
        color != null ? ((color.a * 255.0).round() & 0xff) : null;
    final int? red8 = color != null ? ((color.r * 255.0).round() & 0xff) : null;
    final int? green8 =
        color != null ? ((color.g * 255.0).round() & 0xff) : null;
    final int? blue8 =
        color != null ? ((color.b * 255.0).round() & 0xff) : null;

    final Map<String, Object?> map = <String, Object?>{
      'id': id,
      'name': name,
      'description': description,
      'groupId': groupId,
      'showBadge': showBadge,
      'importance': importance.value,
      'bypassDnd': bypassDnd,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'enableLights': enableLights,
      'ledColorAlpha': alpha8,
      'ledColorRed': red8,
      'ledColorGreen': green8,
      'ledColorBlue': blue8,
      'audioAttributesUsage': audioAttributesUsage.value,
      'channelAction': AndroidNotificationChannelAction.createIfNotExists.index,
    }..addAll(_convertNotificationSoundToMap(sound));

    return map;
  }
}

extension AndroidNotificationTitleStyleMapper on AndroidNotificationTitleStyle {
  Map<String, Object?> toMap() {
    final Map<String, Object?> map = <String, Object?>{};
    if (color != null) {
      assert(color! >= 0 && color! <= 0xFFFFFFFF);
      map['color'] = color;
    }
    if (sizeSp != null) {
      map['sizeSp'] = sizeSp;
    }
    if (bold != null) {
      map['bold'] = bold;
    }
    if (italic != null) {
      map['italic'] = italic;
    }
    if (iconSpacing != null) {
      assert(iconSpacing! >= 0);
      map['iconSpacingDp'] = iconSpacing;
    }
    assert(map.keys.toSet().length == map.length);
    assert(map.values.every((Object? v) => v != null));
    return map;
  }
}

extension AndroidNotificationDescriptionStyleMapper
    on AndroidNotificationDescriptionStyle {
  Map<String, Object?> toMap() {
    final Map<String, Object?> map = <String, Object?>{};
    if (color != null) {
      assert(color! >= 0 && color! <= 0xFFFFFFFF);
      map['color'] = color;
    }
    if (sizeSp != null) {
      map['sizeSp'] = sizeSp;
    }
    if (bold != null) {
      map['bold'] = bold;
    }
    if (italic != null) {
      map['italic'] = italic;
    }
    assert(map.keys.toSet().length == map.length);
    assert(map.values.every((Object? v) => v != null));
    return map;
  }
}

Map<String, Object> _convertNotificationSoundToMap(
    AndroidNotificationSound? sound) {
  if (sound is RawResourceAndroidNotificationSound) {
    return <String, Object>{
      'sound': sound.sound,
      'soundSource': AndroidNotificationSoundSource.rawResource.index,
    };
  } else if (sound is UriAndroidNotificationSound) {
    return <String, Object>{
      'sound': sound.sound,
      'soundSource': AndroidNotificationSoundSource.uri.index,
    };
  } else {
    return <String, Object>{};
  }
}

extension PersonMapper on Person {
  Map<String, Object?> toMap() => <String, Object?>{
        'bot': bot,
        'important': important,
        'key': key,
        'name': name,
        'uri': uri
      }..addAll(_convertIconToMap());

  Map<String, Object> _convertIconToMap() {
    if (icon == null) {
      return <String, Object>{};
    }
    return <String, Object>{
      'icon': icon!.data,
      'iconSource': icon!.source.index,
    };
  }
}

extension DefaultStyleInformationMapper on DefaultStyleInformation {
  Map<String, Object?> toMap() => _convertDefaultStyleInformationToMap(this);
}

Map<String, Object?> _convertDefaultStyleInformationToMap(
        DefaultStyleInformation styleInformation) =>
    <String, Object?>{
      'htmlFormatContent': styleInformation.htmlFormatContent,
      'htmlFormatTitle': styleInformation.htmlFormatTitle
    };

extension BigPictureStyleInformationMapper on BigPictureStyleInformation {
  Map<String, Object?> toMap() => _convertDefaultStyleInformationToMap(this)
    ..addAll(_convertBigPictureToMap())
    ..addAll(_convertLargeIconToMap())
    ..addAll(<String, Object?>{
      'contentTitle': contentTitle,
      'summaryText': summaryText,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'htmlFormatSummaryText': htmlFormatSummaryText,
      'hideExpandedLargeIcon': hideExpandedLargeIcon
    });

  Map<String, Object> _convertBigPictureToMap() => <String, Object>{
        'bigPicture': bigPicture.data,
        'bigPictureBitmapSource': bigPicture.source.index,
      };

  Map<String, Object> _convertLargeIconToMap() {
    if (largeIcon == null) {
      return <String, Object>{};
    }
    return <String, Object>{
      'largeIcon': largeIcon!.data,
      'largeIconBitmapSource': largeIcon!.source.index,
    };
  }
}

extension BigTexStyleInformationMapper on BigTextStyleInformation {
  Map<String, Object?> toMap() => _convertDefaultStyleInformationToMap(this)
    ..addAll(<String, Object?>{
      'bigText': bigText,
      'htmlFormatBigText': htmlFormatBigText,
      'contentTitle': contentTitle,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'summaryText': summaryText,
      'htmlFormatSummaryText': htmlFormatSummaryText
    });
}

extension InboxStyleInformationMapper on InboxStyleInformation {
  Map<String, Object?> toMap() => _convertDefaultStyleInformationToMap(this)
    ..addAll(<String, Object?>{
      'contentTitle': contentTitle,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'summaryText': summaryText,
      'htmlFormatSummaryText': htmlFormatSummaryText,
      'lines': lines,
      'htmlFormatLines': htmlFormatLines
    });
}

extension MessagingStyleInformationMapper on MessagingStyleInformation {
  Map<String, Object?> toMap() => _convertDefaultStyleInformationToMap(this)
    ..addAll(<String, Object?>{
      'person': person.toMap(),
      'conversationTitle': conversationTitle,
      'groupConversation': groupConversation,
      'messages': messages
          ?.map((m) => m.toMap()) // ignore: always_specify_types
          .toList()
    });
}

extension AndroidNotificationDetailsMapper on AndroidNotificationDetails {
  Map<String, Object?> toMap() {
    final Color? c = color, lc = ledColor; // cache to enable promotion
    return <String, Object?>{
      'icon': icon,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'channelShowBadge': channelShowBadge,
      'channelAction': channelAction.index,
      'importance': importance.value,
      'channelBypassDnd': channelBypassDnd,
      'priority': priority.value,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'groupKey': groupKey,
      'setAsGroupSummary': setAsGroupSummary,
      'groupAlertBehavior': groupAlertBehavior.index,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'silent': silent,

      // color (nullable) — use a/r/g/b doubles -> 0–255 ints
      'colorAlpha': c != null ? ((c.a * 255.0).round() & 0xff) : null,
      'colorRed': c != null ? ((c.r * 255.0).round() & 0xff) : null,
      'colorGreen': c != null ? ((c.g * 255.0).round() & 0xff) : null,
      'colorBlue': c != null ? ((c.b * 255.0).round() & 0xff) : null,

      'onlyAlertOnce': onlyAlertOnce,
      'showWhen': showWhen,
      'when': when,
      'usesChronometer': usesChronometer,
      'chronometerCountDown': chronometerCountDown,
      'showProgress': showProgress,
      'maxProgress': maxProgress,
      'progress': progress,
      'indeterminate': indeterminate,
      'enableLights': enableLights,

      // ledColor (nullable) — also switch off deprecated getters
      'ledColorAlpha': lc != null ? ((lc.a * 255.0).round() & 0xff) : null,
      'ledColorRed': lc != null ? ((lc.r * 255.0).round() & 0xff) : null,
      'ledColorGreen': lc != null ? ((lc.g * 255.0).round() & 0xff) : null,
      'ledColorBlue': lc != null ? ((lc.b * 255.0).round() & 0xff) : null,

      'ledOnMs': ledOnMs,
      'ledOffMs': ledOffMs,
      'ticker': ticker,
      'visibility': visibility?.index,
      'timeoutAfter': timeoutAfter,
      'category': category?.name,
      'fullScreenIntent': fullScreenIntent,
      'shortcutId': shortcutId,
      'additionalFlags': additionalFlags,
      'subText': subText,
      'tag': tag,
      'colorized': colorized,
      'number': number,
      'audioAttributesUsage': audioAttributesUsage.value,
      'titleStyle': titleStyle?.toMap(),
      'descriptionStyle': descriptionStyle?.toMap(),
    }
      ..addAll(_convertActionsToMap(actions))
      ..addAll(_convertStyleInformationToMap())
      ..addAll(_convertNotificationSoundToMap(sound))
      ..addAll(_convertLargeIconToMap());
  }

  Map<String, Object?> _convertStyleInformationToMap() {
    if (styleInformation is BigPictureStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.bigPicture.index,
        'styleInformation':
            (styleInformation as BigPictureStyleInformation?)?.toMap(),
      };
    } else if (styleInformation is BigTextStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.bigText.index,
        'styleInformation':
            (styleInformation as BigTextStyleInformation?)?.toMap(),
      };
    } else if (styleInformation is InboxStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.inbox.index,
        'styleInformation':
            (styleInformation as InboxStyleInformation?)?.toMap(),
      };
    } else if (styleInformation is MessagingStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.messaging.index,
        'styleInformation':
            (styleInformation as MessagingStyleInformation?)?.toMap(),
      };
    } else if (styleInformation is MediaStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.media.index,
        'styleInformation':
            (styleInformation as MediaStyleInformation?)?.toMap(),
      };
    } else if (styleInformation is DefaultStyleInformation) {
      return <String, Object?>{
        'style': AndroidNotificationStyle.defaultStyle.index,
        'styleInformation':
            (styleInformation as DefaultStyleInformation?)?.toMap(),
      };
    } else {
      return <String, Object>{
        'style': AndroidNotificationStyle.defaultStyle.index,
        'styleInformation': const DefaultStyleInformation(false, false).toMap(),
      };
    }
  }

  Map<String, Object> _convertLargeIconToMap() {
    if (largeIcon == null) {
      return <String, Object>{};
    }
    return <String, Object>{
      'largeIcon': largeIcon!.data,
      'largeIconBitmapSource': largeIcon!.source.index,
    };
  }

  Map<String, Object> _convertActionsToMap(
      List<AndroidNotificationAction>? actions) {
    if (actions == null) {
      return <String, Object>{};
    }
    return <String, Object>{
      'actions': actions
          .map(
            (AndroidNotificationAction e) => <String, dynamic>{
              'id': e.id,
              'title': e.title,
              'titleColorAlpha': e.titleColor != null
                  ? ((e.titleColor!.a * 255.0).round() & 0xff)
                  : null,
              'titleColorRed': e.titleColor != null
                  ? ((e.titleColor!.r * 255.0).round() & 0xff)
                  : null,
              'titleColorGreen': e.titleColor != null
                  ? ((e.titleColor!.g * 255.0).round() & 0xff)
                  : null,
              'titleColorBlue': e.titleColor != null
                  ? ((e.titleColor!.b * 255.0).round() & 0xff)
                  : null,
              if (e.icon != null) ...<String, Object>{
                'icon': e.icon!.data,
                'iconBitmapSource': e.icon!.source.index,
              },
              'contextual': e.contextual,
              'showsUserInterface': e.showsUserInterface,
              'allowGeneratedReplies': e.allowGeneratedReplies,
              'inputs': e.inputs
                  .map((AndroidNotificationActionInput input) =>
                      _convertInputToMap(input))
                  .toList(),
              'cancelNotification': e.cancelNotification,
              'semanticAction': e.semanticAction.value,
              'invisible': e.invisible,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> _convertInputToMap(
          AndroidNotificationActionInput input) =>
      <String, dynamic>{
        'choices': input.choices,
        'allowFreeFormInput': input.allowFreeFormInput,
        'label': input.label,
        'allowedMimeType': input.allowedMimeTypes.toList(),
      };
}
