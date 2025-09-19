# Android Setup

> [!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

If something isn't clear, keep in mind the [example app](https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example) has all of this setup done already, so you can use it as a reference.

This guide will only handle the setup that comes before compiling your application. For details on what this plugin can do and how to use it, see the [Android Usage Guide](android-usage.md).

## Gradle and Kotlin

Gradle is Android's build system, and controls important options during compilation. There are two similarly named files, The **Project build file** (`android/build.gradle`), and the **Module build file** (`android/app/build.gradle`). Pay close attention to which one is being referred to in the following sections before making modifications.

Gradle files also come in two syntaxes:
1. Groovy (legacy): `build.gradle`
2. Kotlin (recommended): `build.gradle.kts`

It is recommended to switch to Kotlin, and new apps created with `flutter create` come with the Kotlin style by default. At the time of writing, however, there are [known performance issues](https://github.com/gradle/gradle/issues/15886) with Kotlin, and switching to Groovy will take time, so these docs will have both styles for reference. If you're looking to migrate, see [this guide](https://developer.android.com/build/migrate-to-kotlin-dsl) from Android and [this guide](https://docs.gradle.org/current/userguide/migrating_from_groovy_to_kotlin_dsl.html) from Gradle.

### Java Desugaring

This plugin relies on [desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring) to take advantage of newer Java features on older versions of Android. Desugaring must be enabled in your _module_ build file, like this:

<details>
<summary>Groovy - <code>android/app/build.gradle</code></summary>

```groovy
android {
  defaultConfig {
    multiDexEnabled true
  }

  compileOptions {
    coreLibraryDesugaringEnabled true
    sourceCompatibility JavaVersion.VERSION_11
    targetCompatibility JavaVersion.VERSION_11
  }

  kotlinOptions {
    jvmTarget = "11"
  }
}

dependencies {
  coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

</details>

<details>
<summary>Kotlin - <code>android/app/build.gradle.kts</code></summary>

```kotlin
android {
  defaultConfig {
    multiDexEnabled = true
  }

  compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
  }

  kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
  }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

</details>

> [!Warning]
> There was [a crash](https://github.com/flutter/flutter/issues/110658) that used to occur on devices running Android 12L and above. Flutter has since fixed the issue in 3.24.0. If you are using an earlier version of Flutter, you'll need to add it manually to your _module_ build file:

<details><summary>Groovy - <code>android/app/build.gradle</code></summary>

```groovy
dependencies {
  implementation 'androidx.window:window:1.0.0'
  implementation 'androidx.window:window-java:1.0.0'
}
```

</details>

<details><summary>Kotlin - <code>android/app/build.gradle.kts</code></summary>

```kotlin
dependencies {
  implementation("androidx.window:window:1.0.0")
  implementation("androidx.window:window-java:1.0.0")
}
```

</details>

### Upgrading the Android Gradle Plugin

This package uses the Android Gradle Plugin (AGP) version 8.6.0, so your application should use that version or higher. Make sure you are using the new declarative plugin syntax by following the guide [here](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply), making sure to use an AGP plugin version of `8.6.0` or higher. Your `android/settings.gradle` file should have this:

<details><summary>Groovy - <code>settings.gradle</code></summary>

```groovy
plugins {
  id "com.android.application" version "8.6.0" apply false
}
```

</details>

<details><summary>Kotlin - <code>settings.gradle.kts</code></summary>

```kotlin
plugins {
  id("com.android.application") version "8.6.0" apply false
}
```

</details>

### Upgrading your minimum Android SDK

This plugin requires Android SDK version 35 or higher. Make sure your _module_ build file sets `compileSdk` to 34 or higher:

<details><summary>Groovy - <code>android/app/build.gradle</code></summary>

```groovy
android {
  compileSdk 35
}
```

</details>

<details><summary>Kotlin - <code>android/app/build.gradle.kts</code></summary>

```kotlin
android {
  compileSdk = 35
}
```

</details>

## AndroidManifest.xml Setup

While Gradle is used to compile your app, [the Android Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro) is used to install and run your app. In this context, the manifest is responsible for declaring what permissions will be needed by the app. The manifest is located at `android/src/main/AndroidManifest.xml`.

This plugin has its own manifest that requires the [`POST_NOTIFICATIONS`](https://developer.android.com/reference/android/Manifest.permission#POST_NOTIFICATIONS) and [`VIBRATE`](https://developer.android.com/reference/android/Manifest.permission#VIBRATE) permissions, but apps that need more advanced functionality must add them as needed. Note that some permissions might require special consent from the user or subject your app to special review from the Play Store.

### Scheduling notifications

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

### Scheduling with precision

By default, Android will only schedule notifications with approximate precision to save power in idle mode. Exact timing differences are not given by the Android docs, but in general, you should not expect your notification to arrive within the exact minute you set it.

> [!Warning]
> Scheduling exact alarms prevents the Android OS from being able to properly optimize the device's energy usage and idle time, and can lead to noticeably worse battery life for your users. Carefully consider whether you actually need these permissions and be mindful of users with lower-performing hardware.

> [!Note]
> Some Android device manufacturers implement non-standard app-killing behavior to extend battery life more aggressively than what the Android docs suggest. This behavior, if it applies to your app, is at the OS level and cannot be prevented by this plugin. See [this site]( https://dontkillmyapp.com) for a rundown of such manufacturers and what you can do for your users.

If you need that level of precision, [you'll need another permission](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms). For example, calendar and alarm apps are encouraged to use these. Take a moment to consider your app's circumstances:

- Exact scheduling is a core requirement for your app. In this case, you'll need the [`USE_EXACT_ALARM`](https://developer.android.com/reference/android/Manifest.permission#USE_EXACT_ALARM) permission, which won't require user consent in-app but may subject your app to more stringent app store reviews.
- Exact scheduling is a nice-to-have addition for your app that users can opt-out of. In this case, you'll want to use the [`SCHEDULE_EXACT_ALARM`](https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM) permission. This permission will need to be granted by the user using [`requestExactAlarmsPermission()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestExactAlarmsPermission.html) function in Dart. This permission can be revoked at any time by the user or system, so use [`canScheduleExactNotifications()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/canScheduleExactNotifications.html) to check at run-time if you still have this permission.

In any case, add the appropriate permission to your manifest, under the top-level `<manifest>` tag.

```xml
<!-- Choose the permission most appropriate for your app -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

Do not request both permissions, choose only one.

### Full-screen notifications

Some apps may need to take over the screen to show their notifications, such as alarms or incoming calls. This requires some modifications to your manifestL

```xml
<manifest ...>
  <!-- Add the necessary permission -->
  <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>

  <application ...>
    <!-- Add these to your .MainActivity -->
    <activity
      ...
      android:showWhenLocked="true"
      android:turnScreenOn="true">
    </activity>
  </application>
</manifest>
```

The [Android docs](https://source.android.com/docs/core/permissions/fsi-limits) indicate that this permission will be automatically revoked for apps that do not provide calling or alarm functionality, so use this permission sparingly. To request the permission at runtime, use [`requestFullScreenIntentPermission()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestFullScreenIntentPermission.html) in your Dart code. A Dart function to check this permission at runtime [does not yet exist](https://github.com/MaikuB/flutter_local_notifications/issues/2478).

### Using notification actions

Android, like most other platforms, supports adding buttons and text inputs to your notifications. These inputs are called actions, and can be to execute an action more specific than just opening the app, like responding to a message or opening to a specific page. To add actions to your app, add the following inside your `<application>` tag:

```xml
<application ...>
  <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
</application>
```

### Using foreground services

A [foreground service](https://developer.android.com/develop/background-work/services/foreground-services) indicates ongoing work in the form of a notification. You can use [`AndroidNotificationDetails.ongoing`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails/ongoing.html) to specify if the notification should be non-dismissible. Note that this plugin does not implement logic in Dart to actually perform the operations, but rather just shows the service notification itself.

Android defines many different types of foreground services. These are just predefined categories and not limitations, but it can still be useful to let the system know what type of service you're running. Refer to [this page](https://developer.android.com/develop/background-work/services/fg-service-types) to find all the different types of services.

At runtime, use [`startForegroundService()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/startForegroundService.html) and pass the appropriate service types, if any. The system will check if you have the necessary permissions for each service type and reject your request if not. The prerequisite permissions can be found at the link above. When you're done, use `stopForegroundService()`.

Foreground services require additions to the manifest. First, you must request the `FOREGROUND_SERVICE` permission, along with special permissions for each service type. Then, you must register the plugin service as shown below, adding any service types you may need. The exact names for each service type can be found at the link above.

```xml
<manifest ...>
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
  <!-- Repeat this line for each service type -->
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MY_SERVICE_TYPE"/>
  <application ...>
    <!-- Customize the foregroundServiceType line below to your needs -->
    <service
      android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
      android:exported="false"
      android:stopWithTask="false"
      android:foregroundServiceType="my_service_type1|my_service_type2" >
    </service>
  </application>
</manifest>
```

### Bypassing Do Not Disturb

If your app will create notifications that will bypass Do Not Disturb, you'll need to declare a special permission in your manifest:

```xml
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
```

You'll also need to request permission at runtime with [`requestNotificationPolicyAccess()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidFlutterLocalNotificationsPlugin/requestNotificationPolicyAccess.html). See the Android usage guide for more details.

## Code and asset shrinking

Flutter enables [code shrinking](https://developer.android.com/build/shrink-code) to minimize the release size by default. This means code and assets that were not determined to be used will automatically be stripped from your compiled application in release mode. This can be fine for Java code, but icons and other assets may be removed as well. Whether you're using the app icon for notifications (the default) or a custom icon, this can affect your app and your notifications or icons may not show.

Be sure to follow the instructions [here](https://developer.android.com/topic/performance/app-optimization/customize-which-resources-to-keep) to protect your application from these problems. Make sure to include any icons or sounds you bundle with your app. If you're using your app icon for notifications, be sure to include `@mipmap/ic_launcher` in your `keep.xml` file as well.

> [!WARNING]
>
> Code shrinking can affect the  [GSON](https://github.com/google/gson) package as well, a Java dependency used by this plugin. Version 19.0.0 of this package includes the necessary ProGuard rules to protect it, but if you're using an earlier version, you'll need to manually copy the contents of [this file](https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg) to `android/app/proguard-rules.pro`.

## Custom icons and sounds

Notification icons should be added as a [drawable resource](https://developer.android.com/guide/topics/resources/drawable-resource), just like app icons. By default, the app's own icon is `@mipmap/ic_launcher`, and any such value can be passed directly to the `AndroidNotificationDetails()` constructor. For more details on creating custom notification icons, [see the docs](https://developer.android.com/studio/write/create-app-icons#create-notification). Custom notification sounds should be added to the `res/raw` directory.

Notifications may also make use of [large icons](https://developer.android.com/develop/ui/views/notifications/expanded#image-style), such as album art or message attachments. When calling `show()`, pass a [`largeIcon`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails/largeIcon.html) to the `AndroidNotificationDetails()` constructor. Use a `DrawableResourceAndroidBitmap` to indicate an image file in `/res/drawable`, or use `FilePathAndroidBitmap` to point to any file.

> [!Warning]
>
> Since these assets are only referred to at runtime, Android Studio might decide these assets are "unused" and remove them from your app in release mode. Be sure to follow the instructions in the previous section to preserve them.
