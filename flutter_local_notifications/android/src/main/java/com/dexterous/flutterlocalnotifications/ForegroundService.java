package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import java.util.ArrayList;

public class ForegroundService extends Service {

  @Override
  @SuppressWarnings("deprecation")
  public int onStartCommand(Intent intent, int flags, int startId) {
    ForegroundServiceStartParameter parameter;
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
      parameter =
          (ForegroundServiceStartParameter)
              intent.getSerializableExtra(
                  ForegroundServiceStartParameter.EXTRA, ForegroundServiceStartParameter.class);
    } else {
      parameter =
          (ForegroundServiceStartParameter)
              intent.getSerializableExtra(ForegroundServiceStartParameter.EXTRA);
    }

    Notification notification =
        FlutterLocalNotificationsPlugin.createNotification(this, parameter.notificationData);
    if (parameter.foregroundServiceTypes != null
        && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      startForeground(
          parameter.notificationData.id,
          notification,
          orCombineFlags(parameter.foregroundServiceTypes));
    } else {
      startForeground(parameter.notificationData.id, notification);
    }
    return parameter.startMode;
  }

  private static int orCombineFlags(ArrayList<Integer> flags) {
    int flag = flags.get(0);
    for (int i = 1; i < flags.size(); i++) {
      flag |= flags.get(i);
    }
    return flag;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }
}
