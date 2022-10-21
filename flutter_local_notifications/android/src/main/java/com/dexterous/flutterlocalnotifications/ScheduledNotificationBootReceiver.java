package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;

@Keep
public class ScheduledNotificationBootReceiver extends BroadcastReceiver {
  @Override
  @SuppressWarnings("deprecation")
  public void onReceive(final Context context, Intent intent) {
    String action = intent.getAction();
    if (action != null) {
      if (action.equals(android.content.Intent.ACTION_BOOT_COMPLETED)
          || action.equals(Intent.ACTION_MY_PACKAGE_REPLACED)
          || action.equals("android.intent.action.QUICKBOOT_POWERON")
          || action.equals("com.htc.intent.action.QUICKBOOT_POWERON")) {
        FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
      }
    }
  }
}
