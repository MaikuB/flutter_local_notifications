package com.dexterous.flutterlocalnotifications;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterLocalNotificationsPlugin
 */
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import java.util.Map;


/**
 * FlutterLocalNotificationsPlugin
 */
public class FlutterLocalNotificationsPlugin implements MethodCallHandler {
  private static final String INITIALIZE_METHOD = "initialize";
  private static final String SHOW_METHOD = "show";
  private static final String CANCEL_METHOD = "cancel";
  private static final String SCHEDULE_METHOD = "schedule";
  private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications";
  private int defaultIconResourceId;

  private final Registrar registrar;

  private FlutterLocalNotificationsPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.registrar.context().registerReceiver(new ScheduledNotificationReceiver(), new IntentFilter());
    ;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
    FlutterLocalNotificationsPlugin plugin = new FlutterLocalNotificationsPlugin(registrar);
    channel.setMethodCallHandler(plugin);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if(call.method.equals(INITIALIZE_METHOD)) {
      Map<String, Object> arguments = call.arguments();
      Map<String, Object> platformSpecifics  = (Map<String, Object>) arguments.get("platformSpecifics");
      String defaultIcon = (String) platformSpecifics.get("defaultIcon");
      defaultIconResourceId = registrar.context().getResources().getIdentifier(defaultIcon, "drawable", registrar.context().getPackageName());
      result.success(null);
    }
    else if (call.method.equals(SHOW_METHOD)) {
      Map<String, Object> arguments = call.arguments();
      NotificationDetails notificationDetails = NotificationDetails.from(arguments);
      showNotification(notificationDetails);
      result.success(null);
    } else if (call.method.equals(SCHEDULE_METHOD)) {
      Map<String, Object> arguments = call.arguments();
      NotificationDetails notificationDetails = NotificationDetails.from(arguments);
      scheduleNotification(notificationDetails);
      result.success(null);
    } else if (call.method.equals(CANCEL_METHOD)) {
      Integer id = call.arguments();
      cancelNotification(id);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private void cancelNotification(Integer id) {
    Context context = registrar.context();
    Intent intent = new Intent(context, ScheduledNotificationReceiver.class);
    PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT);
    AlarmManager alarmManager = getAlarmManager();
    alarmManager.cancel(pendingIntent);
    NotificationManagerCompat notificationManager = getNotificationManager();
    notificationManager.cancel(id);
  }

  private void showNotification(NotificationDetails notificationDetails) {
    Notification notification = createNotification(notificationDetails);
    NotificationManagerCompat notificationManagerCompat = getNotificationManager();
    notificationManagerCompat.notify(notificationDetails.id, notification);
  }

  private void scheduleNotification(NotificationDetails notificationDetails) {
    Context context = registrar.context();
    Notification notification = createNotification(notificationDetails);
    Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
    notificationIntent.putExtra(ScheduledNotificationReceiver.NOTIFICATION_ID, notificationDetails.id);
    notificationIntent.putExtra(ScheduledNotificationReceiver.NOTIFICATION, notification);
    PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationDetails.id, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);
    AlarmManager alarmManager = getAlarmManager();
    alarmManager.set(AlarmManager.RTC_WAKEUP, notificationDetails.delay, pendingIntent);
  }

  private Notification createNotification(NotificationDetails notificationDetails) {
    Context context = registrar.context();

    int resourceId = 0;
    if (notificationDetails.icon != null) {
      resourceId = context.getResources().getIdentifier(notificationDetails.icon, "drawable", context.getPackageName());
    } else {
      resourceId = defaultIconResourceId;
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
      NotificationChannel notificationChannel = notificationManager.getNotificationChannel(notificationDetails.channelId);
      if(notificationChannel == null) {
        notificationChannel = new NotificationChannel(notificationDetails.channelId, notificationDetails.channelName,  notificationDetails.importance);
        notificationChannel.setDescription(notificationDetails.channelDescription);
        notificationManager.createNotificationChannel(notificationChannel);
      }
    }
    NotificationCompat.Builder builder = new NotificationCompat.Builder(context, notificationDetails.channelId)
            .setSmallIcon(resourceId)
            .setContentTitle(notificationDetails.title)
            .setContentText(notificationDetails.body)
            .setAutoCancel(true)
            .setPriority(notificationDetails.priority);
    Notification notification = builder.build();
    return notification;
  }

  private NotificationManagerCompat getNotificationManager() {
    return NotificationManagerCompat.from(registrar.context());
  }

  private AlarmManager getAlarmManager() {
    AlarmManager alarmManager = (AlarmManager) registrar.context().getSystemService(Context.ALARM_SERVICE);
    return alarmManager;
  }

}
