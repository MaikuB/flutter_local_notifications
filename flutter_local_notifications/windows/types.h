#ifndef FLUTTER_LOCAL_NOTIFICATION_TYPES_H_
#define FLUTTER_LOCAL_NOTIFICATION_TYPES_H_

#include <flutter/encodable_value.h>
#include <flutter/method_call.h>
#include <flutter/method_channel.h>
#include <flutter/method_result.h>

using FlutterMap = flutter::EncodableMap;
using FlutterList = flutter::EncodableList;
using FlutterMethodCall = flutter::MethodCall<flutter::EncodableValue>;
using FlutterMethodResult = flutter::MethodResult<flutter::EncodableValue>;
using PluginMethodChannel = flutter::MethodChannel<flutter::EncodableValue>;

#endif
