package com.dexterous.flutterlocalnotifications;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.text.Html;
import android.text.Spanned;

import com.dexterous.flutterlocalnotifications.models.IconSource;
import com.dexterous.flutterlocalnotifications.models.MessageDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.models.PersonDetails;
import com.dexterous.flutterlocalnotifications.models.styles.BigPictureStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.BigTextStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.DefaultStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.InboxStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.MessagingStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.StyleInformation;
import com.dexterous.flutterlocalnotifications.utils.BooleanUtils;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.Person;
import androidx.core.graphics.drawable.IconCompat;
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
    /*public static final String ON_NOTIFICATION_ACTION = "onNotification";
    public static final String ON_NOTIFICATION_ARGS = "onNotificationArgs";
    public static final String CALLBACK_DISPATCHER = "callbackDispatcher";
    public static final String ON_NOTIFICATION_CALLBACK_DISPATCHER = "onNotificationCallbackDispatcher";*/
    public static final String SHARED_PREFERENCES_KEY = "notification_plugin_cache";
    private static final String DRAWABLE = "drawable";
    private static final String DEFAULT_ICON = "defaultIcon";
    private static final String SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
    private static final String SCHEDULED_NOTIFICATIONS = "scheduled_notifications";
    private static final String INITIALIZE_METHOD = "initialize";
    private static final String INITIALIZE_HEADLESS_SERVICE_METHOD = "initializeHeadlessService";
    private static final String SHOW_METHOD = "show";
    private static final String CANCEL_METHOD = "cancel";
    private static final String CANCEL_ALL_METHOD = "cancelAll";
    private static final String SCHEDULE_METHOD = "schedule";
    private static final String PERIODICALLY_SHOW_METHOD = "periodicallyShow";
    private static final String SHOW_DAILY_AT_TIME_METHOD = "showDailyAtTime";
    private static final String SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD = "showWeeklyAtDayAndTime";
    private static final String GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD = "getNotificationAppLaunchDetails";
    private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications";
    private static final String PAYLOAD = "payload";
    private static final String INVALID_ICON_ERROR_CODE = "INVALID_ICON";
    private static final String INVALID_LARGE_ICON_ERROR_CODE = "INVALID_LARGE_ICON";
    private static final String INVALID_BIG_PICTURE_ERROR_CODE = "INVALID_BIG_PICTURE";
    private static final String INVALID_SOUND_ERROR_CODE = "INVALID_SOUND";
    private static final String NOTIFICATION_LAUNCHED_APP = "notificationLaunchedApp";
    private static final String INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE = "The resource %s could not be found. Please make sure it has been added as a drawable resource to your Android head project.";
    private static final String INVALID_RAW_RESOURCE_ERROR_MESSAGE = "The resource %s could not be found. Please make sure it has been added as a raw resource to your Android head project.";
    public static String NOTIFICATION_ID = "notification_id";
    public static String NOTIFICATION = "notification";
    public static String NOTIFICATION_DETAILS = "notificationDetails";
    public static String REPEAT = "repeat";
    private MethodChannel channel;
    private static int defaultIconResourceId;
    private final Registrar registrar;

    private FlutterLocalNotificationsPlugin(Registrar registrar) {
        this.registrar = registrar;
        this.registrar.addNewIntentListener(this);
        this.channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
        this.channel.setMethodCallHandler(this);
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

    public static Notification createNotification(Context context, NotificationDetails notificationDetails) {
        setupNotificationChannel(context, notificationDetails);
        Intent intent = new Intent(context, getMainActivityClass(context));
        intent.setAction(SELECT_NOTIFICATION);
        intent.putExtra(PAYLOAD, notificationDetails.payload);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, notificationDetails.id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        DefaultStyleInformation defaultStyleInformation = (DefaultStyleInformation) notificationDetails.styleInformation;
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, notificationDetails.channelId)
                .setSmallIcon(notificationDetails.iconResourceId)
                .setContentTitle(defaultStyleInformation.htmlFormatTitle ? fromHtml(notificationDetails.title) : notificationDetails.title)
                .setContentText(defaultStyleInformation.htmlFormatBody ? fromHtml(notificationDetails.body) : notificationDetails.body)
                .setAutoCancel(BooleanUtils.getValue(notificationDetails.autoCancel))
                .setContentIntent(pendingIntent)
                .setPriority(notificationDetails.priority)
                .setOngoing(BooleanUtils.getValue(notificationDetails.ongoing))
                .setOnlyAlertOnce(BooleanUtils.getValue(notificationDetails.onlyAlertOnce));

        if (!StringUtils.isNullOrEmpty(notificationDetails.largeIcon)) {
            builder.setLargeIcon(getBitmapFromSource(context, notificationDetails.largeIcon, notificationDetails.largeIconBitmapSource));
        }
        if (notificationDetails.color != null) {
            builder.setColor(notificationDetails.color.intValue());
        }

        applyGrouping(notificationDetails, builder);
        setSound(context, notificationDetails, builder);
        setVibrationPattern(notificationDetails, builder);
        setStyle(context, notificationDetails, builder);
        setProgress(notificationDetails, builder);
        return builder.build();
    }

    @NonNull
    public static Gson buildGson() {
        RuntimeTypeAdapterFactory<StyleInformation> styleInformationAdapter =
                RuntimeTypeAdapterFactory
                        .of(StyleInformation.class)
                        .registerSubtype(DefaultStyleInformation.class)
                        .registerSubtype(BigTextStyleInformation.class)
                        .registerSubtype(BigPictureStyleInformation.class)
                        .registerSubtype(InboxStyleInformation.class)
                        .registerSubtype(MessagingStyleInformation.class);
        GsonBuilder builder = new GsonBuilder().registerTypeAdapterFactory(styleInformationAdapter);
        return builder.create();
    }

    private static ArrayList<NotificationDetails> loadScheduledNotifications(Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = new ArrayList<>();
        SharedPreferences sharedPreferences = context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
        String json = sharedPreferences.getString(SCHEDULED_NOTIFICATIONS, null);
        if (json != null) {
            Gson gson = buildGson();
            Type type = new TypeToken<ArrayList<NotificationDetails>>() {
            }.getType();
            scheduledNotifications = gson.fromJson(json, type);
        }
        return scheduledNotifications;
    }


    private static void saveScheduledNotifications(Context context, ArrayList<NotificationDetails> scheduledNotifications) {
        Gson gson = buildGson();
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
        FlutterLocalNotificationsPlugin plugin = new FlutterLocalNotificationsPlugin(registrar);
    }

    public static void removeNotificationFromCache(Integer notificationId, Context context) {
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        for (Iterator<NotificationDetails> it = scheduledNotifications.iterator(); it.hasNext(); ) {
            NotificationDetails notificationDetails = it.next();
            if (notificationDetails.id.equals(notificationId)) {
                it.remove();
                break;
            }
        }
        saveScheduledNotifications(context, scheduledNotifications);
    }

    @SuppressWarnings("deprecation")
    private static Spanned fromHtml(String html) {
        if (html == null) {
            return null;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
        } else {
            return Html.fromHtml(html);
        }
    }

    private static void scheduleNotification(Context context, NotificationDetails notificationDetails, Boolean updateScheduledNotificationsCache) {
        Gson gson = buildGson();
        String notificationDetailsJson = gson.toJson(notificationDetails);
        Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, notificationDetails.id, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        AlarmManager alarmManager = getAlarmManager(context);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, notificationDetails.millisecondsSinceEpoch, pendingIntent);
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, notificationDetails.millisecondsSinceEpoch, pendingIntent);

        }
        if (updateScheduledNotificationsCache) {
            ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
            scheduledNotifications.add(notificationDetails);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    private static void repeatNotification(Context context, NotificationDetails notificationDetails, Boolean updateScheduledNotificationsCache) {
        Gson gson = buildGson();
        String notificationDetailsJson = gson.toJson(notificationDetails);
        Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
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
        if (notificationDetails.repeatTime != null) {
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

        // ensure that start time is in the future
        long currentTime = System.currentTimeMillis();
        while (startTimeMilliseconds < currentTime) {
            startTimeMilliseconds += repeatInterval;
        }

        alarmManager.setInexactRepeating(AlarmManager.RTC_WAKEUP, startTimeMilliseconds, repeatInterval, pendingIntent);

        if (updateScheduledNotificationsCache) {
            ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
            scheduledNotifications.add(notificationDetails);
            saveScheduledNotifications(context, scheduledNotifications);
        }
    }

    private static boolean setIconResourceId(Context context, NotificationDetails notificationDetails, Result result) {
        if (notificationDetails.iconResourceId == null) {
            int resourceId;
            if (notificationDetails.icon != null) {
                resourceId = context.getResources().getIdentifier(notificationDetails.icon, DRAWABLE, context.getPackageName());
                if (resourceId == 0) {
                    result.error(INVALID_ICON_ERROR_CODE, String.format(INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE, notificationDetails.icon), null);
                }
            } else {
                resourceId = defaultIconResourceId;
            }
            notificationDetails.iconResourceId = resourceId;
        }

        return notificationDetails.iconResourceId != 0;
    }

    private static int getDrawableResourceId(Context context, String name) {
        return context.getResources().getIdentifier(name, DRAWABLE, context.getPackageName());
    }

    private static Bitmap getBitmapFromSource(Context context, String bitmapPath, BitmapSource bitmapSource) {
        Bitmap bitmap = null;
        if (bitmapSource == BitmapSource.Drawable) {
            bitmap = BitmapFactory.decodeResource(context.getResources(), getDrawableResourceId(context, bitmapPath));
        } else if (bitmapSource == BitmapSource.FilePath) {
            bitmap = BitmapFactory.decodeFile(bitmapPath);
        }

        return bitmap;
    }

    private static IconCompat getIconFromSource(Context context, String iconPath, IconSource iconSource) {
        IconCompat icon = null;
        switch (iconSource) {
            case Drawable:
                icon = IconCompat.createWithResource(context, getDrawableResourceId(context, iconPath));
                break;
            case FilePath:
                icon = IconCompat.createWithBitmap(BitmapFactory.decodeFile(iconPath));
                break;
            case ContentUri:
                icon = IconCompat.createWithContentUri(iconPath);
                break;
            default:
                break;
        }
        return icon;
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

    private static void setStyle(Context context, NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        switch (notificationDetails.style) {
            case Default:
                break;
            case BigPicture:
                setBigPictureStyle(context, notificationDetails, builder);
                break;
            case BigText:
                setBigTextStyle(notificationDetails, builder);
                break;
            case Inbox:
                setInboxStyle(notificationDetails, builder);
                break;
            case Messaging:
                setMessagingStyle(context, notificationDetails, builder);
                break;
            default:
                break;
        }
    }

    private static void setProgress(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        if (BooleanUtils.getValue(notificationDetails.showProgress)) {
            builder.setProgress(notificationDetails.maxProgress, notificationDetails.progress, notificationDetails.indeterminate);
        }
    }

    private static void setBigPictureStyle(Context context, NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        BigPictureStyleInformation bigPictureStyleInformation = (BigPictureStyleInformation) notificationDetails.styleInformation;
        NotificationCompat.BigPictureStyle bigPictureStyle = new NotificationCompat.BigPictureStyle();
        if (bigPictureStyleInformation.contentTitle != null) {
            CharSequence contentTitle = bigPictureStyleInformation.htmlFormatContentTitle ? fromHtml(bigPictureStyleInformation.contentTitle) : bigPictureStyleInformation.contentTitle;
            bigPictureStyle.setBigContentTitle(contentTitle);
        }
        if (bigPictureStyleInformation.summaryText != null) {
            CharSequence summaryText = bigPictureStyleInformation.htmlFormatSummaryText ? fromHtml(bigPictureStyleInformation.summaryText) : bigPictureStyleInformation.summaryText;
            bigPictureStyle.setSummaryText(summaryText);
        }

        if (bigPictureStyleInformation.hideExpandedLargeIcon) {
            bigPictureStyle.bigLargeIcon(null);
        } else {
            if (bigPictureStyleInformation.largeIcon != null) {
                bigPictureStyle.bigLargeIcon(getBitmapFromSource(context, bigPictureStyleInformation.largeIcon, bigPictureStyleInformation.largeIconBitmapSource));
            }
        }
        bigPictureStyle.bigPicture(getBitmapFromSource(context, bigPictureStyleInformation.bigPicture, bigPictureStyleInformation.bigPictureBitmapSource));
        builder.setStyle(bigPictureStyle);
    }

    private static void setInboxStyle(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
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
    }


    private static void setMessagingStyle(Context context, NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
        MessagingStyleInformation messagingStyleInformation = (MessagingStyleInformation) notificationDetails.styleInformation;
        Person person = buildPerson(context, messagingStyleInformation.person);
        NotificationCompat.MessagingStyle messagingStyle = new NotificationCompat.MessagingStyle(person);
        messagingStyle.setGroupConversation(BooleanUtils.getValue(messagingStyleInformation.groupConversation));
        if (messagingStyleInformation.conversationTitle != null) {
            messagingStyle.setConversationTitle(messagingStyleInformation.conversationTitle);
        }
        if (messagingStyleInformation.messages != null && !messagingStyleInformation.messages.isEmpty()) {
            for (Iterator<MessageDetails> it = messagingStyleInformation.messages.iterator(); it.hasNext(); ) {
                NotificationCompat.MessagingStyle.Message message = createMessage(context, it.next());
                messagingStyle.addMessage(message);
            }
        }
        builder.setStyle(messagingStyle);
    }

    private static NotificationCompat.MessagingStyle.Message createMessage(Context context, MessageDetails messageDetails) {
        NotificationCompat.MessagingStyle.Message message = new NotificationCompat.MessagingStyle.Message(messageDetails.text, messageDetails.timestamp, buildPerson(context, messageDetails.person));
        if (messageDetails.dataUri != null && messageDetails.dataMimeType != null) {
            message.setData(messageDetails.dataMimeType, Uri.parse(messageDetails.dataUri));
        }
        return message;
    }

    private static Person buildPerson(Context context, PersonDetails personDetails) {
        if (personDetails == null) {
            return null;
        }

        Person.Builder personBuilder = new Person.Builder();
        personBuilder.setBot(BooleanUtils.getValue(personDetails.bot));
        if (personDetails.icon != null && personDetails.iconBitmapSource != null) {
            personBuilder.setIcon(getIconFromSource(context, personDetails.icon, personDetails.iconBitmapSource));
        }
        personBuilder.setImportant(BooleanUtils.getValue(personDetails.important));
        if (personDetails.key != null) {
            personBuilder.setKey(personDetails.key);
        }
        if (personDetails.name != null) {
            personBuilder.setName(personDetails.name);
        }
        if (personDetails.uri != null) {
            personBuilder.setUri(personDetails.uri);
        }
        return personBuilder.build();
    }

    private static void setBigTextStyle(NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
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
                notificationChannel.setShowBadge(BooleanUtils.getValue(notificationDetails.channelShowBadge));
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
        return (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    }

    private static boolean isValidDrawableResource(Context context, String name, Result result, String errorCode) {
        int resourceId = context.getResources().getIdentifier(name, DRAWABLE, context.getPackageName());
        if (resourceId == 0) {
            result.error(errorCode, String.format(INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE, name), null);
            return false;
        }
        return true;
    }

    public static void showNotification(Context context, NotificationDetails notificationDetails) {
        Notification notification = createNotification(context, notificationDetails);
        NotificationManagerCompat notificationManagerCompat = getNotificationManager(context);
        notificationManagerCompat.notify(notificationDetails.id, notification);
        /*SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        if(sharedPreferences.contains(ON_NOTIFICATION_CALLBACK_DISPATCHER)) {
            long callbackHandle = sharedPreferences.getLong(ON_NOTIFICATION_CALLBACK_DISPATCHER, 0);
            HashMap<String, Object> callbackArgs = new HashMap<>();
            callbackArgs.put(CALLBACK_DISPATCHER, callbackHandle);
            callbackArgs.put(NotificationDetails.ID, notificationDetails.id);
            callbackArgs.put(NotificationDetails.TITLE, notificationDetails.title);
            callbackArgs.put(NotificationDetails.BODY, notificationDetails.body);
            callbackArgs.put(PAYLOAD, notificationDetails.payload);
            Intent intent = new Intent(context, NotificationService.class);
            intent.setAction(ON_NOTIFICATION_ACTION);
            intent.putExtra(ON_NOTIFICATION_ARGS, callbackArgs);
            NotificationService.enqueueWork(context, intent);
        }*/
    }

    /*private void initializeHeadlessService(MethodCall call, Result result) {
        Map<String, Object> arguments = call.arguments();
        SharedPreferences sharedPreferences = registrar.context().getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();

        if(arguments.containsKey(CALLBACK_DISPATCHER)) {
            Object callbackDispatcher = arguments.get(CALLBACK_DISPATCHER);
            if (callbackDispatcher instanceof Long) {
                editor.putLong(CALLBACK_DISPATCHER, (Long) callbackDispatcher);
            } else if (callbackDispatcher instanceof Integer) {
                editor.putLong(CALLBACK_DISPATCHER, (Integer) callbackDispatcher);
            }
        } else if(sharedPreferences.contains(CALLBACK_DISPATCHER)){
            editor.remove(CALLBACK_DISPATCHER);
        }

        if(arguments.containsKey(ON_NOTIFICATION_CALLBACK_DISPATCHER)) {
            Object onNotificationCallbackDispatcher = arguments.get(ON_NOTIFICATION_CALLBACK_DISPATCHER);
            if(onNotificationCallbackDispatcher instanceof Long) {
                editor.putLong(ON_NOTIFICATION_CALLBACK_DISPATCHER, (Long)onNotificationCallbackDispatcher);
            } else if(onNotificationCallbackDispatcher instanceof Integer) {
                editor.putLong(ON_NOTIFICATION_CALLBACK_DISPATCHER, (Integer)onNotificationCallbackDispatcher);
            }
        } else if(sharedPreferences.contains(ON_NOTIFICATION_CALLBACK_DISPATCHER)){
            editor.remove(ON_NOTIFICATION_CALLBACK_DISPATCHER);
        }

        editor.commit();
    }*/

    private static NotificationManagerCompat getNotificationManager(Context context) {
        return NotificationManagerCompat.from(context);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {

            case INITIALIZE_METHOD: {
                // initializeHeadlessService(call, result);
                initialize(call, result);
                break;
            }
            case GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD: {
                getNotificationAppLaunchDetails(result);
                break;
            }
            case SHOW_METHOD: {
                show(call, result);
                break;
            }
            case SCHEDULE_METHOD: {
                schedule(call, result);
                break;
            }
            case PERIODICALLY_SHOW_METHOD:
            case SHOW_DAILY_AT_TIME_METHOD:
            case SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD: {
                repeat(call, result);
                break;
            }
            case CANCEL_METHOD:
                cancel(call, result);
                break;
            case CANCEL_ALL_METHOD:
                cancelAllNotifications(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void cancel(MethodCall call, Result result) {
        Integer id = call.arguments();
        cancelNotification(id);
        result.success(null);
    }

    private void repeat(MethodCall call, Result result) {
        Map<String, Object> arguments = call.arguments();
        NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
        if (notificationDetails != null) {
            repeatNotification(registrar.context(), notificationDetails, true);
            result.success(null);
        }
    }

    private void schedule(MethodCall call, Result result) {
        Map<String, Object> arguments = call.arguments();
        NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
        if (notificationDetails != null) {
            scheduleNotification(registrar.context(), notificationDetails, true);
            result.success(null);
        }
    }

    private void show(MethodCall call, Result result) {
        Map<String, Object> arguments = call.arguments();
        NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
        if (notificationDetails != null) {
            showNotification(registrar.context(), notificationDetails);
            result.success(null);
        }
    }

    private void getNotificationAppLaunchDetails(Result result) {
        Map<String, Object> notificationAppLaunchDetails = new HashMap<>();
        String payload = null;
        Boolean notificationLaunchedApp = (registrar.activity() != null && SELECT_NOTIFICATION.equals(registrar.activity().getIntent().getAction()));
        notificationAppLaunchDetails.put(NOTIFICATION_LAUNCHED_APP, notificationLaunchedApp);
        if (notificationLaunchedApp) {
            payload = registrar.activity().getIntent().getStringExtra(PAYLOAD);
        }
        notificationAppLaunchDetails.put(PAYLOAD, payload);
        result.success(notificationAppLaunchDetails);
    }

    private void initialize(MethodCall call, Result result) {
        Map<String, Object> arguments = call.arguments();
        String defaultIcon = (String) arguments.get(DEFAULT_ICON);
        defaultIconResourceId = registrar.context().getResources().getIdentifier(defaultIcon, "drawable", registrar.context().getPackageName());
        if (defaultIconResourceId == 0) {
            result.error(INVALID_ICON_ERROR_CODE, String.format(INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE, defaultIcon), null);
            return;
        }
        if (registrar.activity() != null) {
            sendNotificationPayloadMessage(registrar.activity().getIntent());
        }
        result.success(true);
    }

    /// Extracts the details of the notifications passed from the Flutter side and also validates that any specified drawable/raw resources exist
    private NotificationDetails extractNotificationDetails(Result result, Map<String, Object> arguments) {
        NotificationDetails notificationDetails = NotificationDetails.from(arguments);
        // validate the icon resource
        if (!setIconResourceId(registrar.context(), notificationDetails, result)) {
            return null;
        }
        if (!StringUtils.isNullOrEmpty(notificationDetails.largeIcon)) {
            // validate the large icon resource
            if (notificationDetails.largeIconBitmapSource == BitmapSource.Drawable) {
                if (!isValidDrawableResource(registrar.context(), notificationDetails.largeIcon, result, INVALID_LARGE_ICON_ERROR_CODE)) {
                    return null;
                }
            }
        }
        if (notificationDetails.style == NotificationStyle.BigPicture) {
            // validate the big picture resources
            BigPictureStyleInformation bigPictureStyleInformation = (BigPictureStyleInformation) notificationDetails.styleInformation;
            if (!StringUtils.isNullOrEmpty(bigPictureStyleInformation.largeIcon)) {
                if (bigPictureStyleInformation.largeIconBitmapSource == BitmapSource.Drawable && !isValidDrawableResource(registrar.context(), bigPictureStyleInformation.largeIcon, result, INVALID_LARGE_ICON_ERROR_CODE)) {
                    return null;
                }
            }
            if (bigPictureStyleInformation.bigPictureBitmapSource == BitmapSource.Drawable && !isValidDrawableResource(registrar.context(), bigPictureStyleInformation.bigPicture, result, INVALID_BIG_PICTURE_ERROR_CODE)) {
                return null;
            }
        }
        if (!StringUtils.isNullOrEmpty(notificationDetails.sound)) {
            int soundResourceId = registrar.context().getResources().getIdentifier(notificationDetails.sound, "raw", registrar.context().getPackageName());
            if (soundResourceId == 0) {
                result.error(INVALID_SOUND_ERROR_CODE, INVALID_RAW_RESOURCE_ERROR_MESSAGE, null);
            }
        }

        return notificationDetails;
    }

    private void cancelNotification(Integer id) {
        Context context = registrar.context();
        Intent intent = new Intent(context, ScheduledNotificationReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, id, intent, PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager alarmManager = getAlarmManager(context);
        alarmManager.cancel(pendingIntent);
        NotificationManagerCompat notificationManager = getNotificationManager(context);
        notificationManager.cancel(id);
        removeNotificationFromCache(id, context);
    }

    private void cancelAllNotifications(Result result) {
        Context context = registrar.context();
        NotificationManagerCompat notificationManager = getNotificationManager(context);
        notificationManager.cancelAll();
        ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
        if (scheduledNotifications == null || scheduledNotifications.isEmpty()) {
            result.success(null);
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
        result.success(null);
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


