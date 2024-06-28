- **[🔧 Android Setup](#-android-setup)**
    - [Gradle setup](#gradle-setup)
    - [AndroidManifest.xml setup](#androidmanifestxml-setup)
    - [Requesting permissions on Android 13 or higher](#requesting-permissions-on-android-13-or-higher)
    - [Custom notification icons and sounds](#custom-notification-icons-and-sounds)
    - [Scheduled notifications](#scheduling-a-notification)
    - [Fullscreen intent notifications](#full-screen-intent-notifications)
    - [Release build configuration](#release-build-configuration)

## 🔧 Android Setup

Before proceeding, please make sure you are using the latest version of the plugin. Note that there have been differences in the setup depending on the version of the plugin used. Please make use of the release tags to refer back to older versions of readme. Applications that schedule notifications should pay close attention to the [AndroidManifest.xml setup](#androidmanifestxml-setup) section of the readme since Android 14 has brought about some behavioural changes.

### Gradle setup

Version 10+ on the plugin now relies on [desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring) to support scheduled notifications with backwards compatibility on older versions of Android. Developers will need to update their application's Gradle file at `android/app/build.gradle`. Please see the link on desugaring for details but the main parts needed in this Gradle file would be

```gradle
android {
  defaultConfig {
    multiDexEnabled true
  }

  compileOptions {
    // Flag to enable support for the new language APIs
    coreLibraryDesugaringEnabled true
    // Sets Java compatibility to Java 8
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
}

dependencies {
  coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.2'
}
```

Note that the plugin uses Android Gradle plugin 7.3.1 to leverage this functionality so to errr on the safe side, applications should aim to use the same version at a **minimum**. Using a higher version is also needed as at point, Android Studio bundled a newer version of the Java SDK that will only work with Gradle 7.3 or higher (see [here](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide) for more details). For a Flutter project, this is specified in `android/build.gradle` and the main parts would look similar to the following

```gradle
buildscript {
   ...

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
        ...
    }
```

There have been reports that enabling desugaring may result in a Flutter apps crashing on Android 12L and above. This would be an issue with Flutter itself, not the plugin. One possible fix is adding the [WindowManager library](https://developer.android.com/jetpack/androidx/releases/window) as a dependency:

```gradle
dependencies {
    implementation 'androidx.window:window:1.0.0'
    implementation 'androidx.window:window-java:1.0.0'
    ...
}
```

More information and other proposed solutions can be found in [Flutter issue #110658](https://github.com/flutter/flutter/issues/110658).

The plugin also requires that the `compileSdk` in your application's Gradle file is set to 34 at a minimum:

```gradle
android {
    compileSdk 34
    ...
}
```

### AndroidManifest.xml setup

Previously the plugin would specify all the permissions required all of the features that the plugin support in its own `AndroidManifest.xml` file so that developers wouldn't need to do this in their own app's `AndroidManifest.xml` file. Since version 16 onwards, the plugin will now only specify the bare minimum and these [`POST_NOTIFICATIONS`] (https://developer.android.com/reference/android/Manifest.permission#POST_NOTIFICATIONS) and [`VIBRATE`](https://developer.android.com/reference/android/Manifest.permission#VIBRATE) permissions.

For apps that need the following functionality please complete the following in your app's `AndroidManifest.xml`

* To schedule notifications the following changes are needed
    * Specify the appropriate permissions between the `<manifest>` tags.
        * `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`: this is required so the plugin can known when the device is rebooted. This is required so that the plugin can reschedule notifications upon a reboot
        * If the app requires scheduling notifications with exact timings (aka exact alarms), there are two options since Android 14 brought about behavioural changes (see [here](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms) for more details)
            * specify `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />` and call the `requestExactAlarmsPermission()` exposed by the `AndroidFlutterNotificationsPlugin` class so that the user can grant the permission via the app or
            * specify `<uses-permission android:name="android.permission.USE_EXACT_ALARM" />`. Users will not be prompted to grant permission, however as per the official Android documentation on the `USE_EXACT_ALARM` permission (refer to [here](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms#calendar-alarm-clock) and [here](https://developer.android.com/reference/android/Manifest.permission#USE_EXACT_ALARM)), this requires the app to target Android 13 (API level 33) or higher and could be subject to approval and auditing by the app store(s) used to publish theapp
    * Specify the following between the `<application>` tags so that the plugin can actually show the scheduled notification(s)
    ```xml
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
        </intent-filter>
    </receiver>
    ```
* To use full-screen intent notifications, specify the `<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />` permission between the `<manifest>` tags.
* To use notification actions, specify `<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />` between the `<application>` tags so that the plugin can process the actions and trigger the appropriate callback(s)

Developers can refer to the example app's `AndroidManifest.xml` to help see what the end result may look like. Do note that the example app covers all the plugin's supported functionality so will request more permissions than your own app may need

### Requesting permissions on Android 13 or higher

From Android 13 (API level 33) onwards, apps now have the ability to display a prompt where users can decide if they want to grant an app permission to show notifications. For further reading on this matter read https://developer.android.com/guide/topics/ui/notifiers/notification-permission. To support this applications need target their application to Android 13 or higher and the compile SDK version needs to be at least 33 (Android 13). For example, to target Android 13, update your app's `build.gradle` file to have a `targetSdkVersion` of `33`. Applications can then call the following code to request the permission where the `requestPermission` method is associated with the `AndroidFlutterLocalNotificationsPlugin` class (i.e. the Android implementation of the plugin)

```
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>().requestNotificationsPermission();
```

### Custom notification icons and sounds

Notification icons should be added as a drawable resource. The example project/code shows how to set default icon for all notifications and how to specify one for each notification. It is possible to use launcher icon/mipmap and this by default is `@mipmap/ic_launcher` in the Android manifest and can be passed `AndroidInitializationSettings` constructor. However, the offical Android guidance is that you should use drawable resources. Custom notification sounds should be added as a raw resource and the sample illustrates how to play a notification with a custom sound. Refer to the following links around Android resources and notification icons.

* [Notifications](https://developer.android.com/studio/write/image-asset-studio#notification)
* [Providing resources](https://developer.android.com/guide/topics/resources/providing-resources)
* [Creating notification icon with Image Asset Studio](https://developer.android.com/studio/write/create-app-icons#create-notification)

When specifying the large icon bitmap or big picture bitmap (associated with the big picture style), bitmaps can be either a drawable resource or file on the device. This is specified via a single property (e.g. the `largeIcon` property associated with the `AndroidNotificationDetails` class) where a value that is an instance of the `DrawableResourceAndroidBitmap` means the bitmap should be loaded from an drawable resource. If this is an instance of the `FilePathAndroidBitmap`, this indicates it should be loaded from a file referred to by a given file path.

⚠️ For Android 8.0+, sounds and vibrations are associated with notification channels and can only be configured when they are first created. Showing/scheduling a notification will create a channel with the specified id if it doesn't exist already. If another notification specifies the same channel id but tries to specify another sound or vibration pattern then nothing occurs.

### Full-screen intent notifications

If your application needs the ability to schedule full-screen intent notifications, add the following attributes to the activity you're opening. For a Flutter application, there is typically only one activity extends from `FlutterActivity`. These attributes ensure the screen turns on and shows when the device is locked.

```xml
<activity
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

For reference, the example app's `AndroidManifest.xml` file can be found [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/AndroidManifest.xml).

Note that when a full-screen intent notification actually occurs (as opposed to a heads-up notification that the system may decide should occur), the plugin will act as though the user has tapped on a notification so handle those the same way (e.g. `onDidReceiveNotificationResponse` callback) to display the appropriate page for your application.

### Release build configuration

Before creating the release build of your app (which is the default setting when building an APK or app bundle) you will need to customise your ProGuard configuration file as per this [link](https://developer.android.com/studio/build/shrink-code#keep-code). Rules specific to the GSON dependency being used by the plugin will need to be added. These rules can be found [here](https://github.com/google/gson/blob/master/examples/android-proguard-example/proguard.cfg). Whilst the example app has a Proguard rules (`proguard-rules.pro`) [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/proguard-rules.pro), it is recommended that developers refer to the rules on the GSON repository in case they get updated over time.

⚠️ Ensure that you have configured the resources that should be kept so that resources like your notification icons aren't discarded by the R8 compiler by following the instructions [here](https://developer.android.com/studio/build/shrink-code#keep-resources). If you have chosen to use `@mipmap/ic_launcher` as the notification icon (against the official Android guidance), be sure to include this in the `keep.xml` file. If you fail to do this, notifications might be broken. In the worst case they will never show, instead silently failing when the system looks for a resource that has been removed. If they do still show, you might not see the icon you specified. The configuration used by the example app can be found [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/res/raw/keep.xml) where it is specifying that all drawable resources should be kept, as well as the file used to play a custom notification sound (sound file is located [here](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/src/main/res/raw/slow_spring_board.mp3)).
