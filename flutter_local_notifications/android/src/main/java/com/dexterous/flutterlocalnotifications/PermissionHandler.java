package com.dexterous.flutterlocalnotifications;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.PluginRegistry;

interface PermissionRequestListener {
  void complete(boolean granted);
}

public class PermissionHandler implements PluginRegistry.RequestPermissionsResultListener {

  static final int NOTIFICATION_PERMISSION_REQUEST_CODE = 1;

  private PermissionRequestListener callback;

  private boolean ongoing;

  public void requestPermission(Activity activity, @NonNull  PermissionRequestListener callback) {
    if (ongoing) {
      Log.w("PermissionHandler", "Permission request is in progress");
      return;
    }

    ongoing = true;
    this.callback = callback;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      Log.d("PermissionHandler", "requestPermission()");

      String permission = Manifest.permission.POST_NOTIFICATIONS;
      boolean permissionGranted = ContextCompat.checkSelfPermission(activity,
              permission) == PackageManager.PERMISSION_GRANTED;

      if (!permissionGranted) {
        ActivityCompat.requestPermissions(activity,
                new String[]{permission},
                NOTIFICATION_PERMISSION_REQUEST_CODE);
      } else {
        ongoing = false;
        this.callback.complete(true);
      }
    } else {
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(activity);
      this.callback.complete(notificationManager.areNotificationsEnabled());
      ongoing = false;
    }
  }


  @Override
  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    Log.d("PermissionHandler", "HERE 1");
    if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
      Log.d("PermissionHandler", "HERE 2");
      boolean granted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
      callback.complete(granted);
      ongoing = false;
      return granted;
    } else {
      ongoing = false;
      return false;
    }
  }
}
