# Local Notifications on Android

>[!Important]
> Before proceeding, please make sure you are using the latest version of the plugin, since some versions require changes to the setup process.

## Setup

While this plugin handles some of the setup, other settings are required on a project basis and therefore must be applied within your project before notifications will work.

If you have already made modifications to these files, please be extra careful and pay attention to context to avoid losing your changes. As always, it is recommended to version control your application to avoid losing changes.

### Gradle Setup

Gradle is Android's build system, and controls important options during compilation. There are two similarly named files, The **Project build file** (`android/build.gradle`), and the **Module build file** (`android/app/build.gradle`). Pay close attention to which one is being referred to in the following sections before making modifications.

#### Java Desugaring

This plugin relies on [desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring) to take advantage of newer Java features on older versions of Android. Desugaring must be enabled in your _project_ build file, like this:

```diff
android {
  defaultConfig {
+   multiDexEnabled true
  }

  compileOptions {
+   coreLibraryDesugaringEnabled true
  }

  dependencies {
+   coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
  }
}
```
