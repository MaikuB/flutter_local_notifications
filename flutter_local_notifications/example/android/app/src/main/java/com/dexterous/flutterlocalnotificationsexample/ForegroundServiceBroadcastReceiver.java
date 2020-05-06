package com.dexterous.flutterlocalnotificationsexample;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import androidx.core.content.ContextCompat;

public class ForegroundServiceBroadcastReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(Context context, Intent intent) {
    Intent foregroundIntent = new Intent(context, ForegroundService.class);
    int notificationId = intent.getIntExtra("notificationId", 1);
    Notification intentNotification = intent.getExtras().getParcelable("notification");
    foregroundIntent.putExtra("notificationId", notificationId);
    foregroundIntent.putExtra("notification", intentNotification);
    ContextCompat.startForegroundService(context, foregroundIntent);
  }
}
