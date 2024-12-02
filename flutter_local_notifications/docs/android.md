# Local Notifications on Android

>[!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

## Setup

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

### Gradle Setup

Gradle is Android's build system, and controls important options during compilation. There are two similarly named files, The **Project build file** (`android/build.gradle`), and the **Module build file** (`android/app/build.gradle`). Pay close attention to which one is being referred to in the following sections before making modifications.

#### Java Desugaring

This plugin relies on [desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring) to take advantage of newer Java features on older versions of Android. Desugaring must be enabled in your _module_ build file, like this:

```diff
android {
  defaultConfig {
+   multiDexEnabled true
  }

  compileOptions {
+   coreLibraryDesugaringEnabled true
  }
}

dependencies {
  // For AGP 7.4+
+ coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
  // For AGP 7.3
+ coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.3'
  // For AGP 4.0 to 7.2
+ coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.1.9'
}
```
For more details, see the link above.

#### Upgrading the Android Gradle Plugin

This package uses AGP 7.3.1, so your package should use that version or higher. Make sure you are using the new declarative plugin syntax by following the guide [here](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply), making sure to use an AGP plugin version of `7.3.1` or higher. Your `android/settings.gradle` file should have this:

```gradle
plugins {
  // Use 7.3.1 or higher
  id "com.android.application" version "7.3.1" apply false
}
```

#### Upgrading your minimum Android SDK

This project requires Android SDK version 34 or higher. Make sure your _module_ build file sets `compileSdk` to 34 or higher:

```gradle
android {
  compileSdk 34
}
```

### AndroidManifest.xml Setup

While Gradle is used to compile your app, [the Android Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro) is used to install and run your app. In this context, the manifest is responsible for declaring what permissions will be needed by the app. The manifest is located at `android/src/main/AndroidManifest.xml`.

This plugin has its own manifest that requires the [`POST_NOTIFICATIONS`](https://developer.android.com/reference/android/Manifest.permission#POST_NOTIFICATIONS) and [`VIBRATE`](https://developer.android.com/reference/android/Manifest.permission#VIBRATE) permissions, but apps that need more advanced functionality must add them as needed. Note that some permissions might require special consent from the user or subject your app to special review from the Play Store.

#### Scheduling Notifications

Scheduled notifications do not survive device reboots. Adding the following line inside the `<manifest>` tag ensures that the plugin can re-schedule notifications as needed.

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Next, add the following receiver inside the `<application>` tag so that the plugin can show the notification when it is triggered.

```xml
<application ...>
  <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
        </intent-filter>
    </receiver>
</application>
```

#### Scheduling with Precision

By default, Android will only schedule notifications with approximate precision to save power in idle mode. Exact timing differences are not given by the Android docs, but in general, you should not expect your notification to arrive within the exact minute you set it.

If you need that level of precision, [you'll need another permission](). For example, calendar and alarm apps are encouraged to use these. Take a moment to consider your app's circumstances:

- Exact scheduling is a core requirement for your app. In this case, you'll need the [`USE_EXACT_ALARM`](https://developer.android.com/reference/android/Manifest.permission#USE_EXACT_ALARM) permission, which won't require user consent in-app but may subject your app to more stringent app store reviews.
- Exact scheduling is a nice-to-have addition for your app that users can opt-out of. In this case, you'll want to use the [`SCHEDULE_EXACT_ALARM`](https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM). This permission will need to be granted by the user using [`requestExactAlarmsPermission()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestExactAlarmsPermission.html) function in Dart. This permission can be revoked at any time by the user or system, so use [`canScheduleExactNotifications`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/canScheduleExactNotifications.html) to check at run-time if you still have this permission.

>[!Warning]
>Scheduling exact alarms prevents the Android OS from being able to properly optimize the device's energy usage and idle time, and can lead to noticeably worse battery life for your users. Carefully consider whether you actually need these permissions and be mindful of users with lower-performing hardware.

In any case, add the appropriate permission to your manifest, under the top-level `<manifest> tag.

```xml
<!-- Choose the permission most appropriate for your app -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

Do not request both permissions, choose only one.
