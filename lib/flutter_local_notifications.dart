library flutter_local_notifications;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

part 'src/platform_specifics/android/styles/style_information.dart';
part 'src/platform_specifics/android/styles/default_style_information.dart';
part 'src/platform_specifics/android/styles/big_text_style_information.dart';
part 'src/platform_specifics/android/styles/inbox_style_information.dart';
part 'src/platform_specifics/android/initialization_settings.dart';
part 'src/platform_specifics/android/notification_details.dart';
part 'src/platform_specifics/ios/initialization_settings.dart';
part 'src/platform_specifics/ios/notification_details.dart';
part 'src/notification_details.dart';
part 'src/initialization_settings.dart';
part 'src/flutter_local_notifications.dart';
