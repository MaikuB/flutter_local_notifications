package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.Keep;
import androidx.annotation.VisibleForTesting;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Keep
public class ScheduledNotificationBootReceiver extends BroadcastReceiver {
  @VisibleForTesting
  ExecutorService createExecutor() {
    return Executors.newSingleThreadExecutor();
  }

  @VisibleForTesting
  void rescheduleNotifications(Context context) {
    FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
  }

  @Override
  @SuppressWarnings("deprecation")
  public void onReceive(final Context context, Intent intent) {
    String action = intent.getAction();
    if (!Intent.ACTION_BOOT_COMPLETED.equals(action)
        && !Intent.ACTION_MY_PACKAGE_REPLACED.equals(action)
        && !"android.intent.action.QUICKBOOT_POWERON".equals(action)
        && !"com.htc.intent.action.QUICKBOOT_POWERON".equals(action)) {
      return;
    }

    final Context applicationContext = context.getApplicationContext();
    final ExecutorService executor = createExecutor();
    final PendingResult pendingResult = goAsync();
    try {
      executor.execute(
          () -> {
            try {
              rescheduleNotifications(applicationContext);
            } finally {
              pendingResult.finish();
              executor.shutdown();
            }
          });
    } catch (RuntimeException exception) {
      pendingResult.finish();
      executor.shutdown();
      throw exception;
    }
  }
}
