package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Keep;

@Keep
public enum IconSource {
  DrawableResource,
  BitmapFilePath,
  ContentUri,
  FlutterBitmapAsset,
  ByteArray
}
