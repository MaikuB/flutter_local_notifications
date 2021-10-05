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
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'name': name,
        'description': description,
        'groupId': groupId,
        'showBadge': showBadge,
        'importance': importance.value,
        'playSound': playSound,
        'enableVibration': enableVibration,
        'vibrationPattern': vibrationPattern,
        'enableLights': enableLights,
        'ledColorAlpha': ledColor?.alpha,
        'ledColorRed': ledColor?.red,
        'ledColorGreen': ledColor?.green,
        'ledColorBlue': ledColor?.blue,
        'channelAction':
            AndroidNotificationChannelAction.createIfNotExists.index,
      }..addAll(_convertNotificationSoundToMap(sound));
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
  Map<String, Object?> toMap() => <String, Object?>{
        'icon': icon,
        'channelId': channelId,
        'channelName': channelName,
        'channelDescription': channelDescription,
        'channelShowBadge': channelShowBadge,
        'channelAction': channelAction.index,
        'importance': importance.value,
        'priority': priority.value,
        'playSound': playSound,
        'enableVibration': enableVibration,
        'vibrationPattern': vibrationPattern,
        'groupKey': groupKey,
        'setAsGroupSummary': setAsGroupSummary,
        'groupAlertBehavior': groupAlertBehavior.index,
        'autoCancel': autoCancel,
        'ongoing': ongoing,
        'colorAlpha': color?.alpha,
        'colorRed': color?.red,
        'colorGreen': color?.green,
        'colorBlue': color?.blue,
        'onlyAlertOnce': onlyAlertOnce,
        'showWhen': showWhen,
        'when': when,
        'usesChronometer': usesChronometer,
        'showProgress': showProgress,
        'maxProgress': maxProgress,
        'progress': progress,
        'indeterminate': indeterminate,
        'enableLights': enableLights,
        'ledColorAlpha': ledColor?.alpha,
        'ledColorRed': ledColor?.red,
        'ledColorGreen': ledColor?.green,
        'ledColorBlue': ledColor?.blue,
        'ledOnMs': ledOnMs,
        'ledOffMs': ledOffMs,
        'ticker': ticker,
        'visibility': visibility?.index,
        'timeoutAfter': timeoutAfter,
        'category': category,
        'fullScreenIntent': fullScreenIntent,
        'shortcutId': shortcutId,
        'additionalFlags': additionalFlags,
        'subText': subText,
        'tag': tag,
      }
        ..addAll(_convertStyleInformationToMap())
        ..addAll(_convertNotificationSoundToMap(sound))
        ..addAll(_convertLargeIconToMap());

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
}
