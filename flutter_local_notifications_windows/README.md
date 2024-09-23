# flutter_local_notifications_windows

The Windows implementation of `package:flutter_local_notifications` as an FFI package that can be run in plain Dart or as a Flutter plugin. See [the docs on FFI](https://dart.dev/interop/c-interop).

## Limitations

- Windows does not support repeating notifications, so [`periodicallyShow`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShow.html) and [`periodicallyShowWithDuration`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/periodicallyShowWithDuration.html) will throw `UnsupportedError`s.
- Windows only allows apps with package identity to retrieve previously shown notifications. This means that on an app that was not packaged as an [MSIX](https://learn.microsoft.com/en-us/windows/msix/overview) installer, [`cancel`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/cancel.html) does nothing and [getActiveNotifications](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin/getActiveNotifications.html) will return an empty list. To package your app as an MSIX, see [`package:msix`](https://pub.dev/packages/msix) and the `msix` section in [the example's `pubspec.yaml`](https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/pubspec.yaml).

## Project structure

This template uses the following structure:

- `src`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library. Within this folder, there are three C++ files:
  - `ffi_api.h`/`ffi_api.cpp`: A C-compatible header file with the API that will be used by Dart, and the C++ implementation of that API
  - `plugin.hpp`/`plugin.cpp`: A C++ class holding handles to the [C++/WinRT](https://learn.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/) SDK, along with some Windows-heavy logic. `ffi_api.cpp` implements its features using this class.
  - `utils.hpp`/`utils.cpp` handle copying and allocating data from C structs to  WinRT classes and vice-versa. Since FFI is done over C-based APIs, C++ types like strings, maps, and vectors need to be translated.

- `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.
  - The `details` folder holds all the Windows-specific notification configurations such as `WindowsAction`, `WindowsImage`, etc.
  - The `ffi` folder holds the generated bindings (see below) and other FFI utilities.
  - The `plugin` folder implements `package:flutter_local_notifications_platform_interface` in two ways: a stub for platforms that don't support FFI, and an FFI-based implementation.

- The `windows` folder contains the build files for building and bundling the native code library with the platform application.

## Building and bundling native code

The code in `src` can be built with CMake. A `build.bat` file is included, which has the following code:

```batch
@echo off
cd build
cmake ../windows
cmake --build .
cd ..
copy build\shared\Debug\flutter_local_notifications_windows.dll .
```

This generates a DLL from the native code and copies it to the current directory. This is useful for testing locally without Flutter. When using Flutter, this step is unnecessary as Flutter will build and bundle the assets for you.

## Binding to native code

To use the native code, bindings in Dart are needed.
To avoid writing these by hand, they are generated from the header file
`src/ffi_api.h` by `package:ffigen`.
Regenerate the bindings by running `dart run ffigen --config ffigen.yaml`.
