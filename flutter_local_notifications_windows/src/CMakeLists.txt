# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_local_notifications_windows_library VERSION 0.0.1 LANGUAGES C)

add_library(flutter_local_notifications_windows SHARED
  "flutter_local_notifications_windows.c"
)

set_target_properties(flutter_local_notifications_windows PROPERTIES
  PUBLIC_HEADER flutter_local_notifications_windows.h
  OUTPUT_NAME "flutter_local_notifications_windows"
)

target_compile_definitions(flutter_local_notifications_windows PUBLIC DART_SHARED_LIB)
