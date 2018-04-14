package com.dexterous.flutterlocalnotifications;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.text.Html;
import android.text.Spanned;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterLocalNotificationsPlugin
 */
public class FlutterLocalNotificationsPlugin implements MethodCallHandler {
    public static final String SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
    private static final String SCHEDULED_NOTIFICATIONS = "scheduled_notifications";
    private static final String INITIALIZE_METHOD = "initialize";
    private static final String SHOW_METHOD = "show";
    private static final String CANCEL_METHOD = "cancel";
    private static final String SCHEDULE_METHOD = "schedule";
    private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications";
    private static MethodChannel channel;
    private static Registrar registrar;
    private static int defaultIconResourceId;

    private FlutterLocalNotificationsPlugin(Registrar registrar) {
        this.registrar = registrar;
        this.registrar.context().registerReceiver(new ScheduledNotificationReceiver(), new IntentFilter());
    }

    public static void rescheduleNotifications(Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        for (int i = 0; i < scheduledNotifications.size(); i++) {
            scheduleNotification(context, scheduledNotifications.get(i), false);
        }
    }

    public static ArrayList<NotificationDetails> loadScheduledNotifications(Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = new ArrayList<>();
        SharedPreferences sharedPreferences = context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
        String json = sharedPreferences.getString(SCHEDULED_NOTIFICATIONS, null);
        System.out.println("json " + json);
        if (json != null) {
            Gson gson = buildScheduledNotificationsGson();
            Type type = new TypeToken<ArrayList<NotificationDetails>>() {
            }.getType();
            scheduledNotifications = gson.fromJson(json, type);
        }
        return scheduledNotifications;
    }

    @NonNull
    private static Gson buildScheduledNotificationsGson() {
        RuntimeTypeAdapterFactory<StyleInformation> styleInformationAdapter =
                RuntimeTypeAdapterFactory
                        .of(StyleInformation.class)
                        .registerSubtype(DefaultStyleInformation.class)
                        .registerSubtype(BigTextStyleInformation.class);
        GsonBuilder builder = new GsonBuilder().registerTypeAdapterFactory(styleInformationAdapter);
        return builder.create();
    }

    public static void saveScheduledNotifications(Context context, ArrayList<NotificationDetails> scheduledNotifications) {
        Gson gson = buildScheduledNotificationsGson();
        String json = gson.toJson(scheduledNotifications);
        SharedPreferences sharedPreferences = context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(SCHEDULED_NOTIFICATIONS, json);
        editor.commit();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
        FlutterLocalNotificationsPlugin plugin = new FlutterLocalNotificationsPlugin(registrar);
        channel.setMethodCallHandler(plugin);
    }

    public static void removeNotificationFromCache(Integer notificationId, Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        ArrayList<NotificationDetails> notificationsToRemove = new ArrayList<>();
        for (int i = 0; i < scheduledNotifications.size(); i++) {
            NotificationDetails notificationDetails = scheduledNotifications.get(i);
            if (notificationDetails.id == notificationId) {
                notificationsToRemove.add(notificationDetails);
            }
        }
        for (int i = 0; i < notificationsToRemove.size(); i++) {
            NotificationDetails notificationToRemove = notificationsToRemove.get(i);
            scheduledNotifications.remove(notificationToRemove);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    @SuppressWarnings("deprecation")
    public static Spanned fromHtml(String html) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
        } else {
            return Html.fromHtml(html);
        }
    }

    private static void scheduleNotification(Context context, NotificationDetails notificationDetails, Boolean updateScheduledNotificationsCache) {
        Notification notification = createNotification(context, notificationDetails);
        Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(ScheduledNotificationReceiver.NOTIFICATION_ID, notificationDetails.id);
        notificationIntent.putExtra(ScheduledNotificationReceiver.NOTIFICATION, notification);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationDetails.id, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        AlarmManager alarmManager = getAlarmManager(context);
        alarmManager.set(AlarmManager.RTC_WAKEUP, notificationDetails.millisecondsSinceEpoch, pendingIntent);
        if (updateScheduledNotificationsCache) {
            ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
            scheduledNotifications.add(notificationDetails);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    private static Notification createNotification(Context context, NotificationDetails notificationDetails) {
        int resourceId;
        if (notificationDetails.icon != null) {
            resourceId = context.getResources().getIdentifier(notificationDetails.icon, "drawable", context.getPackageName());
        } else {
            resourceId = defaultIconResourceId;
        }
        setupNotificationChannel(context, notificationDetails);
        Intent intent = new Intent(context, getMainActivityClass(context));
        intent.setAction(SELECT_NOTIFICATION);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, notificationDetails.id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        DefaultStyleInformation defaultStyleInformation = (DefaultStyleInformation) notificationDetails.styleInformation;
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, notificationDetails.channelId)
                .setSmallIcon(resourceId)
                .setContentTitle(defaultStyleInformation.htmlFormatTitle ? fromHtml(notificationDetails.title) : notificationDetails.title)
                .setContentText(defaultStyleInformation.htmlFormatBody ? fromHtml(notificationDetails.body) : notificationDetails.body)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setPriority(notificationDetails.priority);
        if (notificationDetails.playSound) {
            Uri uri = retrieveSoundResourceUri(context, notificationDetails);
            builder.setSound(uri);
        } else {
            builder.setSound(null);
        }

        if (notificationDetails.enableVibration) {
            if (notificationDetails.vibrationPattern != null && notificationDetails.vibrationPattern.length > 0) {
                builder.setVibrate(notificationDetails.vibrationPattern);
            }
        } else {
            builder.setVibrate(new long[]{0});
        }
        ApplyNotificationStyle(notificationDetails, builder);
        Notification notification = builder.build();
        return notification;
    }

    private static Class getMainActivityClass(Context context) {
        String packageName = context.getPackageName();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        String className = launchIntent.getComponent().getClassName();
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    private static void ApplyNotificationStyle(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        switch (notificationDetails.style) {
            case Default:
                break;
            case BigText:
                BigTextStyleInformation bigTextStyleInformation = (BigTextStyleInformation) notificationDetails.styleInformation;
                NotificationCompat.BigTextStyle bigTextStyle = new NotificationCompat.BigTextStyle();
                if (bigTextStyleInformation.bigText != null) {
                    CharSequence bigText = bigTextStyleInformation.htmlFormatBigText ? fromHtml(bigTextStyleInformation.bigText) : bigTextStyleInformation.bigText;
                    bigTextStyle.bigText(bigText);
                }
                if (bigTextStyleInformation.contentTitle != null) {
                    CharSequence contentTitle = bigTextStyleInformation.htmlFormatContentTitle ? fromHtml(bigTextStyleInformation.contentTitle) : bigTextStyleInformation.contentTitle;
                    bigTextStyle.setBigContentTitle(contentTitle);
                }
                if (bigTextStyleInformation.summaryText != null) {
                    CharSequence summaryText = bigTextStyleInformation.htmlFormatSummaryText ? fromHtml(bigTextStyleInformation.summaryText) : bigTextStyleInformation.summaryText;
                    bigTextStyle.setSummaryText(summaryText);
                }
                builder.setStyle(bigTextStyle);
                break;
        }
    }

    private static void setupNotificationChannel(Context context, NotificationDetails notificationDetails) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            NotificationChannel notificationChannel = notificationManager.getNotificationChannel(notificationDetails.channelId);
            if (notificationChannel == null) {
                notificationChannel = new NotificationChannel(notificationDetails.channelId, notificationDetails.channelName, notificationDetails.importance);
                notificationChannel.setDescription(notificationDetails.channelDescription);
                if (notificationDetails.playSound) {
                    AudioAttributes audioAttributes = new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION).build();
                    Uri uri = retrieveSoundResourceUri(context, notificationDetails);
                    notificationChannel.setSound(uri, audioAttributes);
                } else {
                    notificationChannel.setSound(null, null);
                }
                notificationChannel.enableVibration(notificationDetails.enableVibration);
                if (notificationDetails.vibrationPattern != null && notificationDetails.vibrationPattern.length > 0) {
                    notificationChannel.setVibrationPattern(notificationDetails.vibrationPattern);
                }
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }
    }

    private static Uri retrieveSoundResourceUri(Context context, NotificationDetails notificationDetails) {
        Uri uri;
        if (notificationDetails.sound == null || notificationDetails.sound.isEmpty()) {
            uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        } else {

            int soundResourceId = context.getResources().getIdentifier(notificationDetails.sound, "raw", context.getPackageName());
            return Uri.parse("android.resource://" + context.getPackageName() + "/" + soundResourceId);
        }
        return uri;
    }

    private static AlarmManager getAlarmManager(Context context) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        return alarmManager;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals(INITIALIZE_METHOD)) {
            Map<String, Object> arguments = call.arguments();
            Map<String, Object> platformSpecifics = (Map<String, Object>) arguments.get("platformSpecifics");
            String defaultIcon = (String) platformSpecifics.get("defaultIcon");
            defaultIconResourceId = registrar.context().getResources().getIdentifier(defaultIcon, "drawable", registrar.context().getPackageName());
            result.success(true);
        } else if (call.method.equals(SHOW_METHOD)) {
            Map<String, Object> arguments = call.arguments();
            NotificationDetails notificationDetails = NotificationDetails.from(arguments);
            showNotification(notificationDetails);
            result.success(null);
        } else if (call.method.equals(SCHEDULE_METHOD)) {
            Map<String, Object> arguments = call.arguments();
            NotificationDetails notificationDetails = NotificationDetails.from(arguments);
            scheduleNotification(registrar.context(), notificationDetails, true);
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
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, id, intent, PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager alarmManager = getAlarmManager(context);
        alarmManager.cancel(pendingIntent);
        NotificationManagerCompat notificationManager = getNotificationManager();
        notificationManager.cancel(id);

        removeNotificationFromCache(id, context);
    }

    private void showNotification(NotificationDetails notificationDetails) {
        Notification notification = createNotification(registrar.context(), notificationDetails);
        NotificationManagerCompat notificationManagerCompat = getNotificationManager();
        notificationManagerCompat.notify(notificationDetails.id, notification);
    }

    private NotificationManagerCompat getNotificationManager() {
        return NotificationManagerCompat.from(registrar.context());
    }

}
