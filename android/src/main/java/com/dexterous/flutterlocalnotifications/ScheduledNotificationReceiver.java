package com.dexterous.flutterlocalnotifications;

import java.util.Date;
import java.util.GregorianCalendar;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationManagerCompat;

/**
 * Created by michaelbui on 24/3/18.
 */

public class ScheduledNotificationReceiver extends BroadcastReceiver {


    @Override
    public void onReceive(final Context context, Intent intent) {
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        Notification notification = intent.getParcelableExtra(FlutterLocalNotificationsPlugin.NOTIFICATION);
        int notificationId = intent.getIntExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 0);
        notificationManager.notify(notificationId, notification);
        boolean repeat = intent.getBooleanExtra(FlutterLocalNotificationsPlugin.REPEAT, false);

        if (repeat) {
            Long repeatTillMS =  intent.getLongExtra( FlutterLocalNotificationsPlugin.REPEAT_TILL, -1L );
            if( repeatTillMS != -1L ){
                Date endDate = new Date( repeatTillMS );
                Date currentTime = new Date( GregorianCalendar.getInstance().getTimeInMillis() );
                if( endDate.after( currentTime ) ){

                    PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationId, intent, PendingIntent.FLAG_CANCEL_CURRENT);
                    AlarmManager alarmManager = getAlarmManager(context);
                    alarmManager.cancel(pendingIntent);

                    FlutterLocalNotificationsPlugin.removeNotificationFromCache(notificationId, context);
                }
            }
            return;
        }

        FlutterLocalNotificationsPlugin.removeNotificationFromCache(notificationId, context);
    }

}
