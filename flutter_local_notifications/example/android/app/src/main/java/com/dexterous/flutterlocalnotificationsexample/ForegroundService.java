package com.dexterous.flutterlocalnotificationsexample;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import androidx.annotation.Nullable;

public class ForegroundService extends Service {


  @Nullable
  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    int notificationId = intent.getIntExtra("notificationId", 1);
    Notification notification = intent.getExtras().getParcelable("notification");
    startForeground(notificationId, notification);
    return START_NOT_STICKY;
  }
}
