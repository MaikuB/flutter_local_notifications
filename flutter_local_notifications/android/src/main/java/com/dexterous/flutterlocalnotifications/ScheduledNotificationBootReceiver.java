package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class ScheduledNotificationBootReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(final Context context, Intent intent) {
        String action = intent.getAction();
        if (action != null) {
            if (action.equals(android.content.Intent.ACTION_BOOT_COMPLETED)
                    || action.equals(Intent.ACTION_MY_PACKAGE_REPLACED)) {
                FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
            }
        }
    }
}
