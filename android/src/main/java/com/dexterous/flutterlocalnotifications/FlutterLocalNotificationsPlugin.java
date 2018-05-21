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

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.models.Time;
import com.dexterous.flutterlocalnotifications.models.styles.BigTextStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.DefaultStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.InboxStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.StyleInformation;
import com.dexterous.flutterlocalnotifications.utils.BooleanUtils;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterLocalNotificationsPlugin
 */
public class FlutterLocalNotificationsPlugin implements MethodCallHandler, PluginRegistry.NewIntentListener {
    private static final String DEFAULT_ICON = "defaultIcon";
    private static final String SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
    private static final String SCHEDULED_NOTIFICATIONS = "scheduled_notifications";
    private static final String INITIALIZE_METHOD = "initialize";
    private static final String SHOW_METHOD = "show";
    private static final String CANCEL_METHOD = "cancel";
    private static final String CANCEL_ALL_METHOD = "cancelAll";
    private static final String SCHEDULE_METHOD = "schedule";
    private static final String PERIODICALLY_SHOW_METHOD = "periodicallyShow";
    private static final String SHOW_DAILY_AT_TIME = "showDailyAtTime";
    private static final String SHOW_WEEKLY_AT_DAY_AND_TIME = "showWeeklyAtDayAndTime";
    private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications";
    private static final String PAYLOAD = "payload";
    public static String NOTIFICATION_ID = "notification_id";
    public static String NOTIFICATION = "notification";
    public static String REPEAT = "repeat";
    private static MethodChannel channel;
    private static int defaultIconResourceId;
    private final Registrar registrar;

    private FlutterLocalNotificationsPlugin(Registrar registrar) {
        this.registrar = registrar;
        this.registrar.context().registerReceiver(new ScheduledNotificationReceiver(), new IntentFilter());
        this.registrar.addNewIntentListener(this);
    }

    public static void rescheduleNotifications(Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        for (Iterator<NotificationDetails> it = scheduledNotifications.iterator(); it.hasNext(); ) {
            NotificationDetails scheduledNotification = it.next();
            if (scheduledNotification.repeatInterval == null) {
                scheduleNotification(context, scheduledNotification, false);
            } else {
                repeatNotification(context, scheduledNotification, false);
            }
        }
    }

    private static ArrayList<NotificationDetails> loadScheduledNotifications(Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = new ArrayList<>();
        SharedPreferences sharedPreferences = context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
        String json = sharedPreferences.getString(SCHEDULED_NOTIFICATIONS, null);
        if (json != null) {
            Gson gson = getGsonBuilder();
            Type type = new TypeToken<ArrayList<NotificationDetails>>() {
            }.getType();
            scheduledNotifications = gson.fromJson(json, type);
        }
        return scheduledNotifications;
    }

    @NonNull
    private static Gson getGsonBuilder() {
        RuntimeTypeAdapterFactory<StyleInformation> styleInformationAdapter =
                RuntimeTypeAdapterFactory
                        .of(StyleInformation.class)
                        .registerSubtype(DefaultStyleInformation.class)
                        .registerSubtype(BigTextStyleInformation.class);
        GsonBuilder builder = new GsonBuilder().registerTypeAdapterFactory(styleInformationAdapter);
        return builder.create();
    }

    private static void saveScheduledNotifications(Context context, ArrayList<NotificationDetails> scheduledNotifications) {
        Gson gson = getGsonBuilder();
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
        for (Iterator<NotificationDetails> it = scheduledNotifications.iterator(); it.hasNext(); ) {
            NotificationDetails notificationDetails = it.next();
            if (notificationDetails.id == notificationId) {
                it.remove();
                break;
            }
        }
        saveScheduledNotifications(context, scheduledNotifications);
    }

    @SuppressWarnings("deprecation")
    private static Spanned fromHtml(String html) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
        } else {
            return Html.fromHtml(html);
        }
    }

    private static void scheduleNotification(Context context, NotificationDetails notificationDetails, Boolean updateScheduledNotificationsCache) {
        Notification notification = createNotification(context, notificationDetails);
        Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(NOTIFICATION_ID, notificationDetails.id);
        notificationIntent.putExtra(NOTIFICATION, notification);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationDetails.id, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        AlarmManager alarmManager = getAlarmManager(context);
        alarmManager.set(AlarmManager.RTC_WAKEUP, notificationDetails.millisecondsSinceEpoch, pendingIntent);
        if (updateScheduledNotificationsCache) {
            ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
            scheduledNotifications.add(notificationDetails);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    private static void repeatNotification(Context context, NotificationDetails notificationDetails, Boolean updateScheduledNotificationsCache) {
        Notification notification = createNotification(context, notificationDetails);
        Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(NOTIFICATION_ID, notificationDetails.id);
        notificationIntent.putExtra(NOTIFICATION, notification);
        notificationIntent.putExtra(REPEAT, true);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationDetails.id, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        AlarmManager alarmManager = getAlarmManager(context);
        long repeatInterval = 0;
        switch (notificationDetails.repeatInterval) {
            case EveryMinute:
                repeatInterval = 60000;
                break;
            case Hourly:
                repeatInterval = 60000 * 60;
                break;
            case Daily:
                repeatInterval = 60000 * 60 * 24;
                break;
            case Weekly:
                repeatInterval = 60000 * 60 * 24 * 7;
                break;
            default:
                break;
        }

        long startTimeMilliseconds = notificationDetails.calledAt;
        if (notificationDetails.repeatTime == null) {
            long currentTime = System.currentTimeMillis();
            while (startTimeMilliseconds < currentTime) {
                startTimeMilliseconds += repeatInterval;
            }
        } else {
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.set(Calendar.HOUR_OF_DAY, notificationDetails.repeatTime.hour);
            calendar.set(Calendar.MINUTE, notificationDetails.repeatTime.minute);
            calendar.set(Calendar.SECOND, notificationDetails.repeatTime.second);
            if (notificationDetails.day != null) {
                calendar.set(Calendar.DAY_OF_WEEK, notificationDetails.day);
            }
            startTimeMilliseconds = calendar.getTimeInMillis();
        }
        alarmManager.setInexactRepeating(AlarmManager.RTC_WAKEUP, startTimeMilliseconds, repeatInterval, pendingIntent);

        if (updateScheduledNotificationsCache) {
            ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
            scheduledNotifications.add(notificationDetails);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    private static Notification createNotification(Context context, NotificationDetails notificationDetails) {
        int resourceId;
        if (notificationDetails.iconResourceId == null) {
            if (notificationDetails.icon != null) {
                resourceId = context.getResources().getIdentifier(notificationDetails.icon, "drawable", context.getPackageName());
            } else {
                resourceId = defaultIconResourceId;
            }
            notificationDetails.iconResourceId = resourceId;
        } else {
            resourceId = notificationDetails.iconResourceId;
        }
        setupNotificationChannel(context, notificationDetails);
        Intent intent = new Intent(context, getMainActivityClass(context));
        intent.setAction(SELECT_NOTIFICATION);
        intent.putExtra(PAYLOAD, notificationDetails.payload);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, notificationDetails.id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        DefaultStyleInformation defaultStyleInformation = (DefaultStyleInformation) notificationDetails.styleInformation;
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, notificationDetails.channelId)
                .setSmallIcon(resourceId)
                .setContentTitle(defaultStyleInformation.htmlFormatTitle ? fromHtml(notificationDetails.title) : notificationDetails.title)
                .setContentText(defaultStyleInformation.htmlFormatBody ? fromHtml(notificationDetails.body) : notificationDetails.body)
                .setAutoCancel(BooleanUtils.getValue(notificationDetails.autoCancel))
                .setContentIntent(pendingIntent)
                .setPriority(notificationDetails.priority)
                .setOngoing(BooleanUtils.getValue(notificationDetails.ongoing));

        if(notificationDetails.color != null) {
            builder.setColor(notificationDetails.color.intValue());
        }

        applyGrouping(notificationDetails, builder);
        setSound(context, notificationDetails, builder);
        setVibrationPattern(notificationDetails, builder);
        setStyle(notificationDetails, builder);
        Notification notification = builder.build();
        return notification;
    }

    private static void applyGrouping(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        Boolean isGrouped = false;
        if (!StringUtils.isNullOrEmpty(notificationDetails.groupKey)) {
            builder.setGroup(notificationDetails.groupKey);
            isGrouped = true;
        }

        if (isGrouped) {
            if (BooleanUtils.getValue(notificationDetails.setAsGroupSummary)) {
                builder.setGroupSummary(true);
            }

            builder.setGroupAlertBehavior(notificationDetails.groupAlertBehavior);
        }
    }

    private static void setVibrationPattern(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        if (BooleanUtils.getValue(notificationDetails.enableVibration)) {
            if (notificationDetails.vibrationPattern != null && notificationDetails.vibrationPattern.length > 0) {
                builder.setVibrate(notificationDetails.vibrationPattern);
            }
        } else {
            builder.setVibrate(new long[]{0});
        }
    }

    private static void setSound(Context context, NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        if (BooleanUtils.getValue(notificationDetails.playSound)) {
            Uri uri = retrieveSoundResourceUri(context, notificationDetails);
            builder.setSound(uri);
        } else {
            builder.setSound(null);
        }
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

    private static void setStyle(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
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
            case Inbox:
                InboxStyleInformation inboxStyleInformation = (InboxStyleInformation) notificationDetails.styleInformation;
                NotificationCompat.InboxStyle inboxStyle = new NotificationCompat.InboxStyle();
                if (inboxStyleInformation.contentTitle != null) {
                    CharSequence contentTitle = inboxStyleInformation.htmlFormatContentTitle ? fromHtml(inboxStyleInformation.contentTitle) : inboxStyleInformation.contentTitle;
                    inboxStyle.setBigContentTitle(contentTitle);
                }
                if (inboxStyleInformation.summaryText != null) {
                    CharSequence summaryText = inboxStyleInformation.htmlFormatSummaryText ? fromHtml(inboxStyleInformation.summaryText) : inboxStyleInformation.summaryText;
                    inboxStyle.setSummaryText(summaryText);
                }
                if (inboxStyleInformation.lines != null) {
                    for (String line : inboxStyleInformation.lines) {
                        inboxStyle.addLine(inboxStyleInformation.htmlFormatLines ? fromHtml(line) : line);
                    }
                }
                builder.setStyle(inboxStyle);
                break;
            default:
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
                notificationChannel.enableVibration(BooleanUtils.getValue(notificationDetails.enableVibration));
                if (notificationDetails.vibrationPattern != null && notificationDetails.vibrationPattern.length > 0) {
                    notificationChannel.setVibrationPattern(notificationDetails.vibrationPattern);
                }
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }
    }

    private static Uri retrieveSoundResourceUri(Context context, NotificationDetails notificationDetails) {
        Uri uri;
        if (StringUtils.isNullOrEmpty(notificationDetails.sound)) {
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
        switch (call.method) {
            case INITIALIZE_METHOD: {
                Map<String, Object> arguments = call.arguments();
                String defaultIcon = (String) arguments.get(DEFAULT_ICON);
                defaultIconResourceId = registrar.context().getResources().getIdentifier(defaultIcon, "drawable", registrar.context().getPackageName());
                if (registrar.activity() != null) {
                    sendNotificationPayloadMessage(registrar.activity().getIntent());
                }
                result.success(true);
                break;
            }
            case SHOW_METHOD: {
                Map<String, Object> arguments = call.arguments();
                NotificationDetails notificationDetails = NotificationDetails.from(arguments);
                showNotification(notificationDetails);
                result.success(null);
                break;
            }
            case SCHEDULE_METHOD: {
                Map<String, Object> arguments = call.arguments();
                NotificationDetails notificationDetails = NotificationDetails.from(arguments);
                scheduleNotification(registrar.context(), notificationDetails, true);
                result.success(null);
                break;
            }
            case PERIODICALLY_SHOW_METHOD:
            case SHOW_DAILY_AT_TIME:
            case SHOW_WEEKLY_AT_DAY_AND_TIME: {
                Map<String, Object> arguments = call.arguments();
                NotificationDetails notificationDetails = NotificationDetails.from(arguments);
                repeatNotification(registrar.context(), notificationDetails, true);
                result.success(null);
                break;
            }
            case CANCEL_METHOD:
                Integer id = call.arguments();
                cancelNotification(id);
                result.success(null);
                break;
            case CANCEL_ALL_METHOD:
                cancelAllNotifications();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
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

    private void cancelAllNotifications() {
        NotificationManagerCompat notificationManager = getNotificationManager();
        notificationManager.cancelAll();
        Context context = registrar.context();
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        if (scheduledNotifications == null || scheduledNotifications.isEmpty()) {
            return;
        }

        Intent intent = new Intent(context, ScheduledNotificationReceiver.class);
        for (NotificationDetails scheduledNotification :
                scheduledNotifications) {
            PendingIntent pendingIntent = PendingIntent.getBroadcast(context, scheduledNotification.id, intent, PendingIntent.FLAG_CANCEL_CURRENT);
            AlarmManager alarmManager = getAlarmManager(context);
            alarmManager.cancel(pendingIntent);
        }

        saveScheduledNotifications(context, new ArrayList<NotificationDetails>());
    }

    private void showNotification(NotificationDetails notificationDetails) {
        Notification notification = createNotification(registrar.context(), notificationDetails);
        NotificationManagerCompat notificationManagerCompat = getNotificationManager();
        notificationManagerCompat.notify(notificationDetails.id, notification);
    }

    private NotificationManagerCompat getNotificationManager() {
        return NotificationManagerCompat.from(registrar.context());
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        return sendNotificationPayloadMessage(intent);
    }

    private Boolean sendNotificationPayloadMessage(Intent intent) {
        if (SELECT_NOTIFICATION.equals(intent.getAction())) {
            String payload = intent.getStringExtra(PAYLOAD);
            channel.invokeMethod("selectNotification", payload);
            return true;
        }
        return false;
    }
}
