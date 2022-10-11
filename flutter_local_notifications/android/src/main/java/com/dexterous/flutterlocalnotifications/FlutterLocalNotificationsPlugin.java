package com.dexterous.flutterlocalnotifications;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.service.notification.StatusBarNotification;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.AlarmManagerCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationCompat.Action.Builder;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.Person;
import androidx.core.app.RemoteInput;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.IconCompat;

import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import com.dexterous.flutterlocalnotifications.models.BitmapSource;
import com.dexterous.flutterlocalnotifications.models.DateTimeComponents;
import com.dexterous.flutterlocalnotifications.models.IconSource;
import com.dexterous.flutterlocalnotifications.models.MessageDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationAction;
import com.dexterous.flutterlocalnotifications.models.NotificationAction.NotificationActionInput;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelAction;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationChannelGroupDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.models.PersonDetails;
import com.dexterous.flutterlocalnotifications.models.ScheduledNotificationRepeatFrequency;
import com.dexterous.flutterlocalnotifications.models.SoundSource;
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

import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

interface PermissionRequestListener {
  void complete(boolean granted);

  void fail(String message);
}

/** FlutterLocalNotificationsPlugin */
@Keep
public class FlutterLocalNotificationsPlugin
    implements MethodCallHandler,
        PluginRegistry.NewIntentListener,
        PluginRegistry.RequestPermissionsResultListener,
        FlutterPlugin,
        ActivityAware {

  static final String PAYLOAD = "payload";
  static final String NOTIFICATION_ID = "notificationId";
  static final String CANCEL_NOTIFICATION = "cancelNotification";
  private static final String SHARED_PREFERENCES_KEY = "notification_plugin_cache";
  private static final String DISPATCHER_HANDLE = "dispatcher_handle";
  private static final String CALLBACK_HANDLE = "callback_handle";
  private static final String DRAWABLE = "drawable";
  private static final String DEFAULT_ICON = "defaultIcon";
  private static final String SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
  private static final String SELECT_FOREGROUND_NOTIFICATION_ACTION =
      "SELECT_FOREGROUND_NOTIFICATION";
  private static final String SCHEDULED_NOTIFICATIONS = "scheduled_notifications";
  private static final String INITIALIZE_METHOD = "initialize";
  private static final String GET_CALLBACK_HANDLE_METHOD = "getCallbackHandle";
  private static final String ARE_NOTIFICATIONS_ENABLED_METHOD = "areNotificationsEnabled";
  private static final String CREATE_NOTIFICATION_CHANNEL_GROUP_METHOD =
      "createNotificationChannelGroup";
  private static final String DELETE_NOTIFICATION_CHANNEL_GROUP_METHOD =
      "deleteNotificationChannelGroup";
  private static final String CREATE_NOTIFICATION_CHANNEL_METHOD = "createNotificationChannel";
  private static final String DELETE_NOTIFICATION_CHANNEL_METHOD = "deleteNotificationChannel";
  private static final String GET_ACTIVE_NOTIFICATION_MESSAGING_STYLE_METHOD =
      "getActiveNotificationMessagingStyle";
  private static final String GET_NOTIFICATION_CHANNELS_METHOD = "getNotificationChannels";
  private static final String START_FOREGROUND_SERVICE = "startForegroundService";
  private static final String STOP_FOREGROUND_SERVICE = "stopForegroundService";
  private static final String PENDING_NOTIFICATION_REQUESTS_METHOD = "pendingNotificationRequests";
  private static final String GET_ACTIVE_NOTIFICATIONS_METHOD = "getActiveNotifications";
  private static final String SHOW_METHOD = "show";
  private static final String CANCEL_METHOD = "cancel";
  private static final String CANCEL_ALL_METHOD = "cancelAll";
  private static final String SCHEDULE_METHOD = "schedule";
  private static final String ZONED_SCHEDULE_METHOD = "zonedSchedule";
  private static final String PERIODICALLY_SHOW_METHOD = "periodicallyShow";
  private static final String SHOW_DAILY_AT_TIME_METHOD = "showDailyAtTime";
  private static final String SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD = "showWeeklyAtDayAndTime";
  private static final String GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD =
      "getNotificationAppLaunchDetails";
  private static final String REQUEST_PERMISSION_METHOD = "requestPermission";
  private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications";
  private static final String INVALID_ICON_ERROR_CODE = "invalid_icon";
  private static final String INVALID_LARGE_ICON_ERROR_CODE = "invalid_large_icon";
  private static final String INVALID_BIG_PICTURE_ERROR_CODE = "invalid_big_picture";
  private static final String INVALID_SOUND_ERROR_CODE = "invalid_sound";
  private static final String INVALID_LED_DETAILS_ERROR_CODE = "invalid_led_details";
  private static final String UNSUPPORTED_OS_VERSION_ERROR_CODE = "unsupported_os_version";
  private static final String GET_ACTIVE_NOTIFICATIONS_ERROR_MESSAGE =
      "Android version must be 6.0 or newer to use getActiveNotifications";
  private static final String GET_NOTIFICATION_CHANNELS_ERROR_CODE = "getNotificationChannelsError";
  private static final String GET_ACTIVE_NOTIFICATION_MESSAGING_STYLE_ERROR_CODE =
      "getActiveNotificationMessagingStyleError";
  private static final String INVALID_LED_DETAILS_ERROR_MESSAGE =
      "Must specify both ledOnMs and ledOffMs to configure the blink cycle on older versions of"
          + " Android before Oreo";
  private static final String NOTIFICATION_LAUNCHED_APP = "notificationLaunchedApp";
  private static final String INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE =
      "The resource %s could not be found. Please make sure it has been added as a drawable"
          + " resource to your Android head project.";
  private static final String INVALID_RAW_RESOURCE_ERROR_MESSAGE =
      "The resource %s could not be found. Please make sure it has been added as a raw resource to"
          + " your Android head project.";
  private static final String PERMISSION_REQUEST_IN_PROGRESS_ERROR_CODE =
      "permissionRequestInProgress";
  private static final String PERMISSION_REQUEST_IN_PROGRESS_ERROR_MESSAGE =
      "Another permission request is already in progress";
  private static final String CANCEL_ID = "id";
  private static final String CANCEL_TAG = "tag";
  private static final String ACTION_ID = "actionId";
  private static final String INPUT_RESULT = "FlutterLocalNotificationsPluginInputResult";
  private static final String INPUT = "input";
  private static final String NOTIFICATION_RESPONSE_TYPE = "notificationResponseType";
  static String NOTIFICATION_DETAILS = "notificationDetails";
  static Gson gson;
  private MethodChannel channel;
  private Context applicationContext;
  private Activity mainActivity;
  static final int NOTIFICATION_PERMISSION_REQUEST_CODE = 1;
  private PermissionRequestListener callback;
  private boolean permissionRequestInProgress = false;

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    FlutterLocalNotificationsPlugin plugin = new FlutterLocalNotificationsPlugin();
    plugin.setActivity(registrar.activity());
    registrar.addNewIntentListener(plugin);
    registrar.addRequestPermissionsResultListener(plugin);
    plugin.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  static void rescheduleNotifications(Context context) {
    ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
    for (NotificationDetails scheduledNotification : scheduledNotifications) {
      if (scheduledNotification.repeatInterval == null) {
        if (scheduledNotification.timeZoneName == null) {
          scheduleNotification(context, scheduledNotification, false);
        } else {
          zonedScheduleNotification(context, scheduledNotification, false);
        }
      } else {
        repeatNotification(context, scheduledNotification, false);
      }
    }
  }

  protected static Notification createNotification(
      Context context, NotificationDetails notificationDetails) {
    NotificationChannelDetails notificationChannelDetails =
        NotificationChannelDetails.fromNotificationDetails(notificationDetails);
    if (canCreateNotificationChannel(context, notificationChannelDetails)) {
      setupNotificationChannel(context, notificationChannelDetails);
    }
    Intent intent = getLaunchIntent(context);
    intent.setAction(SELECT_NOTIFICATION);
    intent.putExtra(NOTIFICATION_ID, notificationDetails.id);
    intent.putExtra(PAYLOAD, notificationDetails.payload);
    int flags = PendingIntent.FLAG_UPDATE_CURRENT;
    if (VERSION.SDK_INT >= VERSION_CODES.M) {
      flags |= PendingIntent.FLAG_IMMUTABLE;
    }
    PendingIntent pendingIntent =
        PendingIntent.getActivity(context, notificationDetails.id, intent, flags);
    DefaultStyleInformation defaultStyleInformation =
        (DefaultStyleInformation) notificationDetails.styleInformation;
    NotificationCompat.Builder builder =
        new NotificationCompat.Builder(context, notificationDetails.channelId)
            .setContentTitle(
                defaultStyleInformation.htmlFormatTitle
                    ? fromHtml(notificationDetails.title)
                    : notificationDetails.title)
            .setContentText(
                defaultStyleInformation.htmlFormatBody
                    ? fromHtml(notificationDetails.body)
                    : notificationDetails.body)
            .setTicker(notificationDetails.ticker)
            .setAutoCancel(BooleanUtils.getValue(notificationDetails.autoCancel))
            .setContentIntent(pendingIntent)
            .setPriority(notificationDetails.priority)
            .setOngoing(BooleanUtils.getValue(notificationDetails.ongoing))
            .setOnlyAlertOnce(BooleanUtils.getValue(notificationDetails.onlyAlertOnce));

    if (notificationDetails.actions != null) {
      // Space out request codes by 16 so even with 16 actions they won't clash
      int requestCode = notificationDetails.id * 16;
      for (NotificationAction action : notificationDetails.actions) {
        IconCompat icon = null;
        if (!TextUtils.isEmpty(action.icon) && action.iconSource != null) {
          icon = getIconFromSource(context, action.icon, action.iconSource);
        }

        Intent actionIntent;
        if (action.showsUserInterface != null && action.showsUserInterface) {
          actionIntent = getLaunchIntent(context);
          actionIntent.setAction(SELECT_FOREGROUND_NOTIFICATION_ACTION);
        } else {
          actionIntent = new Intent(context, ActionBroadcastReceiver.class);
          actionIntent.setAction(ActionBroadcastReceiver.ACTION_TAPPED);
        }

        actionIntent
            .putExtra(NOTIFICATION_ID, notificationDetails.id)
            .putExtra(ACTION_ID, action.id)
            .putExtra(CANCEL_NOTIFICATION, action.cancelNotification)
            .putExtra(PAYLOAD, notificationDetails.payload);
        int actionFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (action.actionInputs == null || action.actionInputs.isEmpty()) {
          if (VERSION.SDK_INT >= VERSION_CODES.M) {
            actionFlags |= PendingIntent.FLAG_IMMUTABLE;
          }
        } else {
          if (VERSION.SDK_INT >= VERSION_CODES.S) {
            actionFlags |= PendingIntent.FLAG_MUTABLE;
          }
        }

        @SuppressLint("UnspecifiedImmutableFlag")
        final PendingIntent actionPendingIntent =
            action.showsUserInterface != null && action.showsUserInterface
                ? PendingIntent.getActivity(context, requestCode++, actionIntent, actionFlags)
                : PendingIntent.getBroadcast(context, requestCode++, actionIntent, actionFlags);

        final Spannable actionTitleSpannable = new SpannableString(action.title);
        if (action.titleColor != null) {
          actionTitleSpannable.setSpan(
              new ForegroundColorSpan(action.titleColor), 0, actionTitleSpannable.length(), 0);
        }

        Builder actionBuilder = new Builder(icon, actionTitleSpannable, actionPendingIntent);

        if (action.contextual != null) {
          actionBuilder.setContextual(action.contextual);
        }
        if (action.showsUserInterface != null) {
          actionBuilder.setShowsUserInterface(action.showsUserInterface);
        }
        if (action.allowGeneratedReplies != null) {
          actionBuilder.setAllowGeneratedReplies(action.allowGeneratedReplies);
        }

        if (action.actionInputs != null) {
          for (NotificationActionInput input : action.actionInputs) {
            RemoteInput.Builder remoteInput =
                new RemoteInput.Builder(INPUT_RESULT).setLabel(input.label);
            if (input.allowFreeFormInput != null) {
              remoteInput.setAllowFreeFormInput(input.allowFreeFormInput);
            }

            if (input.allowedMimeTypes != null) {
              for (String mimeType : input.allowedMimeTypes) {
                remoteInput.setAllowDataType(mimeType, true);
              }
            }
            if (input.choices != null) {
              remoteInput.setChoices(input.choices.toArray(new CharSequence[] {}));
            }
            actionBuilder.addRemoteInput(remoteInput.build());
          }
        }
        builder.addAction(actionBuilder.build());
      }
    }

    setSmallIcon(context, notificationDetails, builder);
    builder.setLargeIcon(
        getBitmapFromSource(
            context, notificationDetails.largeIcon, notificationDetails.largeIconBitmapSource));
    if (notificationDetails.color != null) {
      builder.setColor(notificationDetails.color.intValue());
    }

    if (notificationDetails.colorized != null) {
      builder.setColorized(notificationDetails.colorized);
    }

    if (notificationDetails.showWhen != null) {
      builder.setShowWhen(BooleanUtils.getValue(notificationDetails.showWhen));
    }

    if (notificationDetails.when != null) {
      builder.setWhen(notificationDetails.when);
    }

    if (notificationDetails.usesChronometer != null) {
      builder.setUsesChronometer(notificationDetails.usesChronometer);
    }

    if (BooleanUtils.getValue(notificationDetails.fullScreenIntent)) {
      builder.setFullScreenIntent(pendingIntent, true);
    }

    if (!StringUtils.isNullOrEmpty(notificationDetails.shortcutId)) {
      builder.setShortcutId(notificationDetails.shortcutId);
    }

    if (!StringUtils.isNullOrEmpty(notificationDetails.subText)) {
      builder.setSubText(notificationDetails.subText);
    }

    if (notificationDetails.number != null) {
      builder.setNumber(notificationDetails.number);
    }

    setVisibility(notificationDetails, builder);
    applyGrouping(notificationDetails, builder);
    setSound(context, notificationDetails, builder);
    setVibrationPattern(notificationDetails, builder);
    setLights(notificationDetails, builder);
    setStyle(context, notificationDetails, builder);
    setProgress(notificationDetails, builder);
    setCategory(notificationDetails, builder);
    setTimeoutAfter(notificationDetails, builder);
    Notification notification = builder.build();
    if (notificationDetails.additionalFlags != null
        && notificationDetails.additionalFlags.length > 0) {
      for (int additionalFlag : notificationDetails.additionalFlags) {
        notification.flags |= additionalFlag;
      }
    }
    return notification;
  }

  private static Boolean canCreateNotificationChannel(
      Context context, NotificationChannelDetails notificationChannelDetails) {
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      NotificationManager notificationManager =
          (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
      NotificationChannel notificationChannel =
          notificationManager.getNotificationChannel(notificationChannelDetails.id);
      // only create/update the channel when needed/specified. Allow this happen to when
      // channelAction may be null to support cases where notifications had been
      // created on older versions of the plugin where channel management options weren't available
      // back then
      return ((notificationChannel == null
              && (notificationChannelDetails.channelAction == null
                  || notificationChannelDetails.channelAction
                      == NotificationChannelAction.CreateIfNotExists))
          || (notificationChannel != null
              && notificationChannelDetails.channelAction == NotificationChannelAction.Update));
    }
    return false;
  }

  private static void setSmallIcon(
      Context context,
      NotificationDetails notificationDetails,
      NotificationCompat.Builder builder) {
    if (!StringUtils.isNullOrEmpty(notificationDetails.icon)) {
      builder.setSmallIcon(getDrawableResourceId(context, notificationDetails.icon));
    } else {
      SharedPreferences sharedPreferences =
          context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
      String defaultIcon = sharedPreferences.getString(DEFAULT_ICON, null);
      if (StringUtils.isNullOrEmpty(defaultIcon)) {
        // for backwards compatibility: this is for handling the old way references to the icon used
        // to be kept but should be removed in future
        builder.setSmallIcon(notificationDetails.iconResourceId);

      } else {
        builder.setSmallIcon(getDrawableResourceId(context, defaultIcon));
      }
    }
  }

  @NonNull
  static Gson buildGson() {
    if (gson == null) {
      RuntimeTypeAdapterFactory<StyleInformation> styleInformationAdapter =
          RuntimeTypeAdapterFactory.of(StyleInformation.class)
              .registerSubtype(DefaultStyleInformation.class)
              .registerSubtype(BigTextStyleInformation.class)
              .registerSubtype(BigPictureStyleInformation.class)
              .registerSubtype(InboxStyleInformation.class)
              .registerSubtype(MessagingStyleInformation.class);
      GsonBuilder builder = new GsonBuilder().registerTypeAdapterFactory(styleInformationAdapter);
      gson = builder.create();
    }
    return gson;
  }

  private static ArrayList<NotificationDetails> loadScheduledNotifications(Context context) {
    ArrayList<NotificationDetails> scheduledNotifications = new ArrayList<>();
    SharedPreferences sharedPreferences =
        context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
    String json = sharedPreferences.getString(SCHEDULED_NOTIFICATIONS, null);
    if (json != null) {
      Gson gson = buildGson();
      Type type = new TypeToken<ArrayList<NotificationDetails>>() {}.getType();
      scheduledNotifications = gson.fromJson(json, type);
    }
    return scheduledNotifications;
  }

  private static void saveScheduledNotifications(
      Context context, ArrayList<NotificationDetails> scheduledNotifications) {
    Gson gson = buildGson();
    String json = gson.toJson(scheduledNotifications);
    SharedPreferences sharedPreferences =
        context.getSharedPreferences(SCHEDULED_NOTIFICATIONS, Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = sharedPreferences.edit();
    editor.putString(SCHEDULED_NOTIFICATIONS, json).apply();
  }

  static void removeNotificationFromCache(Context context, Integer notificationId) {
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
    if (VERSION.SDK_INT >= VERSION_CODES.N) {
      return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
    } else {
      return Html.fromHtml(html);
    }
  }

  private static void scheduleNotification(
      Context context,
      final NotificationDetails notificationDetails,
      Boolean updateScheduledNotificationsCache) {
    Gson gson = buildGson();
    String notificationDetailsJson = gson.toJson(notificationDetails);
    Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
    notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
    PendingIntent pendingIntent =
        getBroadcastPendingIntent(context, notificationDetails.id, notificationIntent);

    AlarmManager alarmManager = getAlarmManager(context);
    if (BooleanUtils.getValue(notificationDetails.allowWhileIdle)) {
      AlarmManagerCompat.setExactAndAllowWhileIdle(
          alarmManager,
          AlarmManager.RTC_WAKEUP,
          notificationDetails.millisecondsSinceEpoch,
          pendingIntent);
    } else {
      AlarmManagerCompat.setExact(
          alarmManager,
          AlarmManager.RTC_WAKEUP,
          notificationDetails.millisecondsSinceEpoch,
          pendingIntent);
    }

    if (updateScheduledNotificationsCache) {
      saveScheduledNotification(context, notificationDetails);
    }
  }

  private static void zonedScheduleNotification(
      Context context,
      final NotificationDetails notificationDetails,
      Boolean updateScheduledNotificationsCache) {
    Gson gson = buildGson();
    String notificationDetailsJson = gson.toJson(notificationDetails);
    Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
    notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
    PendingIntent pendingIntent =
        getBroadcastPendingIntent(context, notificationDetails.id, notificationIntent);
    AlarmManager alarmManager = getAlarmManager(context);
    long epochMilli =
        ZonedDateTime.of(
                LocalDateTime.parse(notificationDetails.scheduledDateTime),
                ZoneId.of(notificationDetails.timeZoneName))
            .toInstant()
            .toEpochMilli();

    if (BooleanUtils.getValue(notificationDetails.allowWhileIdle)) {
      AlarmManagerCompat.setExactAndAllowWhileIdle(
          alarmManager, AlarmManager.RTC_WAKEUP, epochMilli, pendingIntent);
    } else {
      AlarmManagerCompat.setExact(alarmManager, AlarmManager.RTC_WAKEUP, epochMilli, pendingIntent);
    }

    if (updateScheduledNotificationsCache) {
      saveScheduledNotification(context, notificationDetails);
    }
  }

  static void scheduleNextRepeatingNotification(
      Context context, NotificationDetails notificationDetails) {
    long repeatInterval = calculateRepeatIntervalMilliseconds(notificationDetails);
    long notificationTriggerTime =
        calculateNextNotificationTrigger(notificationDetails.calledAt, repeatInterval);
    Gson gson = buildGson();
    String notificationDetailsJson = gson.toJson(notificationDetails);
    Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
    notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
    PendingIntent pendingIntent =
        getBroadcastPendingIntent(context, notificationDetails.id, notificationIntent);
    AlarmManager alarmManager = getAlarmManager(context);
    AlarmManagerCompat.setExactAndAllowWhileIdle(
        alarmManager, AlarmManager.RTC_WAKEUP, notificationTriggerTime, pendingIntent);
    saveScheduledNotification(context, notificationDetails);
  }

  static Map<String, Object> extractNotificationResponseMap(Intent intent) {
    final int notificationId = intent.getIntExtra(NOTIFICATION_ID, 0);
    final Map<String, Object> notificationResponseMap = new HashMap<>();
    notificationResponseMap.put(NOTIFICATION_ID, notificationId);
    notificationResponseMap.put(ACTION_ID, intent.getStringExtra(ACTION_ID));
    notificationResponseMap.put(
        FlutterLocalNotificationsPlugin.PAYLOAD,
        intent.getStringExtra(FlutterLocalNotificationsPlugin.PAYLOAD));

    Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
    if (remoteInput != null) {
      notificationResponseMap.put(INPUT, remoteInput.getString(INPUT_RESULT));
    }

    if (SELECT_NOTIFICATION.equals(intent.getAction())) {
      notificationResponseMap.put(NOTIFICATION_RESPONSE_TYPE, 0);
    }

    if (SELECT_FOREGROUND_NOTIFICATION_ACTION.equals(intent.getAction())) {
      notificationResponseMap.put(NOTIFICATION_RESPONSE_TYPE, 1);
    }

    return notificationResponseMap;
  }

  private static PendingIntent getBroadcastPendingIntent(Context context, int id, Intent intent) {
    int flags = PendingIntent.FLAG_UPDATE_CURRENT;
    if (VERSION.SDK_INT >= VERSION_CODES.M) {
      flags |= PendingIntent.FLAG_IMMUTABLE;
    }
    return PendingIntent.getBroadcast(context, id, intent, flags);
  }

  private static void repeatNotification(
      Context context,
      NotificationDetails notificationDetails,
      Boolean updateScheduledNotificationsCache) {
    long repeatInterval = calculateRepeatIntervalMilliseconds(notificationDetails);

    long notificationTriggerTime = notificationDetails.calledAt;
    if (notificationDetails.repeatTime != null) {
      Calendar calendar = Calendar.getInstance();
      calendar.setTimeInMillis(System.currentTimeMillis());
      calendar.set(Calendar.HOUR_OF_DAY, notificationDetails.repeatTime.hour);
      calendar.set(Calendar.MINUTE, notificationDetails.repeatTime.minute);
      calendar.set(Calendar.SECOND, notificationDetails.repeatTime.second);
      if (notificationDetails.day != null) {
        calendar.set(Calendar.DAY_OF_WEEK, notificationDetails.day);
      }

      notificationTriggerTime = calendar.getTimeInMillis();
    }

    notificationTriggerTime =
        calculateNextNotificationTrigger(notificationTriggerTime, repeatInterval);

    Gson gson = buildGson();
    String notificationDetailsJson = gson.toJson(notificationDetails);
    Intent notificationIntent = new Intent(context, ScheduledNotificationReceiver.class);
    notificationIntent.putExtra(NOTIFICATION_DETAILS, notificationDetailsJson);
    PendingIntent pendingIntent =
        getBroadcastPendingIntent(context, notificationDetails.id, notificationIntent);
    AlarmManager alarmManager = getAlarmManager(context);

    if (BooleanUtils.getValue(notificationDetails.allowWhileIdle)) {
      AlarmManagerCompat.setExactAndAllowWhileIdle(
          alarmManager, AlarmManager.RTC_WAKEUP, notificationTriggerTime, pendingIntent);
    } else {
      alarmManager.setInexactRepeating(
          AlarmManager.RTC_WAKEUP, notificationTriggerTime, repeatInterval, pendingIntent);
    }
    if (updateScheduledNotificationsCache) {
      saveScheduledNotification(context, notificationDetails);
    }
  }

  private static long calculateNextNotificationTrigger(
      long notificationTriggerTime, long repeatInterval) {
    // ensures that time is in the future
    long currentTime = System.currentTimeMillis();
    while (notificationTriggerTime < currentTime) {
      notificationTriggerTime += repeatInterval;
    }
    return notificationTriggerTime;
  }

  private static long calculateRepeatIntervalMilliseconds(NotificationDetails notificationDetails) {
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
    return repeatInterval;
  }

  private static void saveScheduledNotification(
      Context context, NotificationDetails notificationDetails) {
    ArrayList<NotificationDetails> scheduledNotifications = loadScheduledNotifications(context);
    ArrayList<NotificationDetails> scheduledNotificationsToSave = new ArrayList<>();
    for (NotificationDetails scheduledNotification : scheduledNotifications) {
      if (scheduledNotification.id.equals(notificationDetails.id)) {
        continue;
      }
      scheduledNotificationsToSave.add(scheduledNotification);
    }
    scheduledNotificationsToSave.add(notificationDetails);
    saveScheduledNotifications(context, scheduledNotificationsToSave);
  }

  private static int getDrawableResourceId(Context context, String name) {
    return context.getResources().getIdentifier(name, DRAWABLE, context.getPackageName());
  }

  @SuppressWarnings("unchecked")
  private static byte[] castObjectToByteArray(Object data) {
    byte[] byteArray;
    // if data is deserialized by gson, it is of the wrong type and we have to convert it
    if (data instanceof ArrayList) {
      List<Double> l = (ArrayList<Double>) data;
      byteArray = new byte[l.size()];
      for (int i = 0; i < l.size(); i++) {
        byteArray[i] = (byte) l.get(i).intValue();
      }
    } else {
      byteArray = (byte[]) data;
    }
    return byteArray;
  }

  private static Bitmap getBitmapFromSource(
      Context context, Object data, BitmapSource bitmapSource) {
    Bitmap bitmap = null;
    if (bitmapSource == BitmapSource.DrawableResource) {
      bitmap =
          BitmapFactory.decodeResource(
              context.getResources(), getDrawableResourceId(context, (String) data));
    } else if (bitmapSource == BitmapSource.FilePath) {
      bitmap = BitmapFactory.decodeFile((String) data);
    } else if (bitmapSource == BitmapSource.ByteArray) {
      byte[] byteArray = castObjectToByteArray(data);
      bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
    }

    return bitmap;
  }

  private static IconCompat getIconFromSource(Context context, Object data, IconSource iconSource) {
    IconCompat icon = null;
    switch (iconSource) {
      case DrawableResource:
        icon =
            IconCompat.createWithResource(context, getDrawableResourceId(context, (String) data));
        break;
      case BitmapFilePath:
        icon = IconCompat.createWithBitmap(BitmapFactory.decodeFile((String) data));
        break;
      case ContentUri:
        icon = IconCompat.createWithContentUri((String) data);
        break;
      case FlutterBitmapAsset:
        try {
          FlutterLoader flutterLoader = FlutterInjector.instance().flutterLoader();
          AssetFileDescriptor assetFileDescriptor =
              context.getAssets().openFd(flutterLoader.getLookupKeyForAsset((String) data));
          FileInputStream fileInputStream = assetFileDescriptor.createInputStream();
          icon = IconCompat.createWithBitmap(BitmapFactory.decodeStream(fileInputStream));
          fileInputStream.close();
          assetFileDescriptor.close();
        } catch (IOException e) {
          throw new RuntimeException(e);
        }
        break;
      case ByteArray:
        byte[] byteArray = castObjectToByteArray(data);
        icon = IconCompat.createWithData(byteArray, 0, byteArray.length);
      default:
        break;
    }
    return icon;
  }

  /**
   * Sets the visibility property to the input Notification Builder
   *
   * @throws IllegalArgumentException If `notificationDetails.visibility` is not null but also not
   *     matches any known index.
   */
  private static void setVisibility(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (notificationDetails.visibility == null) {
      return;
    }

    int visibility;
    switch (notificationDetails.visibility) {
      case 0: // Private
        visibility = NotificationCompat.VISIBILITY_PRIVATE;
        break;
      case 1: // Public
        visibility = NotificationCompat.VISIBILITY_PUBLIC;
        break;
      case 2: // Secret
        visibility = NotificationCompat.VISIBILITY_SECRET;
        break;

      default:
        throw new IllegalArgumentException("Unknown index: " + notificationDetails.visibility);
    }

    builder.setVisibility(visibility);
  }

  private static void applyGrouping(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    boolean isGrouped = false;
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

  private static void setVibrationPattern(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (BooleanUtils.getValue(notificationDetails.enableVibration)) {
      if (notificationDetails.vibrationPattern != null
          && notificationDetails.vibrationPattern.length > 0) {
        builder.setVibrate(notificationDetails.vibrationPattern);
      }
    } else {
      builder.setVibrate(new long[] {0});
    }
  }

  private static void setLights(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (BooleanUtils.getValue(notificationDetails.enableLights)
        && notificationDetails.ledOnMs != null
        && notificationDetails.ledOffMs != null) {
      builder.setLights(
          notificationDetails.ledColor, notificationDetails.ledOnMs, notificationDetails.ledOffMs);
    }
  }

  private static void setSound(
      Context context,
      NotificationDetails notificationDetails,
      NotificationCompat.Builder builder) {
    if (BooleanUtils.getValue(notificationDetails.playSound)) {
      Uri uri =
          retrieveSoundResourceUri(
              context, notificationDetails.sound, notificationDetails.soundSource);
      builder.setSound(uri);
    } else {
      builder.setSound(null);
    }
  }

  private static void setCategory(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (notificationDetails.category == null) {
      return;
    }
    builder.setCategory(notificationDetails.category);
  }

  private static void setTimeoutAfter(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (notificationDetails.timeoutAfter == null) {
      return;
    }
    builder.setTimeoutAfter(notificationDetails.timeoutAfter);
  }

  private static Intent getLaunchIntent(Context context) {
    String packageName = context.getPackageName();
    PackageManager packageManager = context.getPackageManager();
    return packageManager.getLaunchIntentForPackage(packageName);
  }

  private static void setStyle(
      Context context,
      NotificationDetails notificationDetails,
      NotificationCompat.Builder builder) {
    switch (notificationDetails.style) {
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
      case Media:
        setMediaStyle(builder);
        break;
      default:
        break;
    }
  }

  private static void setProgress(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    if (BooleanUtils.getValue(notificationDetails.showProgress)) {
      builder.setProgress(
          notificationDetails.maxProgress,
          notificationDetails.progress,
          notificationDetails.indeterminate);
    }
  }

  private static void setBigPictureStyle(
      Context context,
      NotificationDetails notificationDetails,
      NotificationCompat.Builder builder) {
    BigPictureStyleInformation bigPictureStyleInformation =
        (BigPictureStyleInformation) notificationDetails.styleInformation;
    NotificationCompat.BigPictureStyle bigPictureStyle = new NotificationCompat.BigPictureStyle();
    if (bigPictureStyleInformation.contentTitle != null) {
      CharSequence contentTitle =
          bigPictureStyleInformation.htmlFormatContentTitle
              ? fromHtml(bigPictureStyleInformation.contentTitle)
              : bigPictureStyleInformation.contentTitle;
      bigPictureStyle.setBigContentTitle(contentTitle);
    }
    if (bigPictureStyleInformation.summaryText != null) {
      CharSequence summaryText =
          bigPictureStyleInformation.htmlFormatSummaryText
              ? fromHtml(bigPictureStyleInformation.summaryText)
              : bigPictureStyleInformation.summaryText;
      bigPictureStyle.setSummaryText(summaryText);
    }

    if (bigPictureStyleInformation.hideExpandedLargeIcon) {
      bigPictureStyle.bigLargeIcon(null);
    } else {
      if (bigPictureStyleInformation.largeIcon != null) {
        bigPictureStyle.bigLargeIcon(
            getBitmapFromSource(
                context,
                bigPictureStyleInformation.largeIcon,
                bigPictureStyleInformation.largeIconBitmapSource));
      }
    }
    bigPictureStyle.bigPicture(
        getBitmapFromSource(
            context,
            bigPictureStyleInformation.bigPicture,
            bigPictureStyleInformation.bigPictureBitmapSource));
    builder.setStyle(bigPictureStyle);
  }

  private static void setInboxStyle(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    InboxStyleInformation inboxStyleInformation =
        (InboxStyleInformation) notificationDetails.styleInformation;
    NotificationCompat.InboxStyle inboxStyle = new NotificationCompat.InboxStyle();
    if (inboxStyleInformation.contentTitle != null) {
      CharSequence contentTitle =
          inboxStyleInformation.htmlFormatContentTitle
              ? fromHtml(inboxStyleInformation.contentTitle)
              : inboxStyleInformation.contentTitle;
      inboxStyle.setBigContentTitle(contentTitle);
    }
    if (inboxStyleInformation.summaryText != null) {
      CharSequence summaryText =
          inboxStyleInformation.htmlFormatSummaryText
              ? fromHtml(inboxStyleInformation.summaryText)
              : inboxStyleInformation.summaryText;
      inboxStyle.setSummaryText(summaryText);
    }
    if (inboxStyleInformation.lines != null) {
      for (String line : inboxStyleInformation.lines) {
        inboxStyle.addLine(inboxStyleInformation.htmlFormatLines ? fromHtml(line) : line);
      }
    }
    builder.setStyle(inboxStyle);
  }

  private static void setMediaStyle(NotificationCompat.Builder builder) {
    androidx.media.app.NotificationCompat.MediaStyle mediaStyle =
        new androidx.media.app.NotificationCompat.MediaStyle();
    builder.setStyle(mediaStyle);
  }

  private static void setMessagingStyle(
      Context context,
      NotificationDetails notificationDetails,
      NotificationCompat.Builder builder) {
    MessagingStyleInformation messagingStyleInformation =
        (MessagingStyleInformation) notificationDetails.styleInformation;
    Person person = buildPerson(context, messagingStyleInformation.person);
    NotificationCompat.MessagingStyle messagingStyle =
        new NotificationCompat.MessagingStyle(person);
    messagingStyle.setGroupConversation(
        BooleanUtils.getValue(messagingStyleInformation.groupConversation));
    if (messagingStyleInformation.conversationTitle != null) {
      messagingStyle.setConversationTitle(messagingStyleInformation.conversationTitle);
    }
    if (messagingStyleInformation.messages != null
        && !messagingStyleInformation.messages.isEmpty()) {
      for (MessageDetails messageDetails : messagingStyleInformation.messages) {
        NotificationCompat.MessagingStyle.Message message = createMessage(context, messageDetails);
        messagingStyle.addMessage(message);
      }
    }
    builder.setStyle(messagingStyle);
  }

  private static NotificationCompat.MessagingStyle.Message createMessage(
      Context context, MessageDetails messageDetails) {
    NotificationCompat.MessagingStyle.Message message =
        new NotificationCompat.MessagingStyle.Message(
            messageDetails.text,
            messageDetails.timestamp,
            buildPerson(context, messageDetails.person));
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
      personBuilder.setIcon(
          getIconFromSource(context, personDetails.icon, personDetails.iconBitmapSource));
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

  private static void setBigTextStyle(
      NotificationDetails notificationDetails, NotificationCompat.Builder builder) {
    BigTextStyleInformation bigTextStyleInformation =
        (BigTextStyleInformation) notificationDetails.styleInformation;
    NotificationCompat.BigTextStyle bigTextStyle = new NotificationCompat.BigTextStyle();
    if (bigTextStyleInformation.bigText != null) {
      CharSequence bigText =
          bigTextStyleInformation.htmlFormatBigText
              ? fromHtml(bigTextStyleInformation.bigText)
              : bigTextStyleInformation.bigText;
      bigTextStyle.bigText(bigText);
    }
    if (bigTextStyleInformation.contentTitle != null) {
      CharSequence contentTitle =
          bigTextStyleInformation.htmlFormatContentTitle
              ? fromHtml(bigTextStyleInformation.contentTitle)
              : bigTextStyleInformation.contentTitle;
      bigTextStyle.setBigContentTitle(contentTitle);
    }
    if (bigTextStyleInformation.summaryText != null) {
      CharSequence summaryText =
          bigTextStyleInformation.htmlFormatSummaryText
              ? fromHtml(bigTextStyleInformation.summaryText)
              : bigTextStyleInformation.summaryText;
      bigTextStyle.setSummaryText(summaryText);
    }
    builder.setStyle(bigTextStyle);
  }

  private static void setupNotificationChannel(
      Context context, NotificationChannelDetails notificationChannelDetails) {
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      NotificationManager notificationManager =
          (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
      NotificationChannel notificationChannel =
          new NotificationChannel(
              notificationChannelDetails.id,
              notificationChannelDetails.name,
              notificationChannelDetails.importance);
      notificationChannel.setDescription(notificationChannelDetails.description);
      notificationChannel.setGroup(notificationChannelDetails.groupId);
      if (notificationChannelDetails.playSound) {
        Integer audioAttributesUsage =
            notificationChannelDetails.audioAttributesUsage != null
                ? notificationChannelDetails.audioAttributesUsage
                : AudioAttributes.USAGE_NOTIFICATION;
        AudioAttributes audioAttributes =
            new AudioAttributes.Builder().setUsage(audioAttributesUsage).build();
        Uri uri =
            retrieveSoundResourceUri(
                context, notificationChannelDetails.sound, notificationChannelDetails.soundSource);
        notificationChannel.setSound(uri, audioAttributes);
      } else {
        notificationChannel.setSound(null, null);
      }
      notificationChannel.enableVibration(
          BooleanUtils.getValue(notificationChannelDetails.enableVibration));
      if (notificationChannelDetails.vibrationPattern != null
          && notificationChannelDetails.vibrationPattern.length > 0) {
        notificationChannel.setVibrationPattern(notificationChannelDetails.vibrationPattern);
      }
      boolean enableLights = BooleanUtils.getValue(notificationChannelDetails.enableLights);
      notificationChannel.enableLights(enableLights);
      if (enableLights && notificationChannelDetails.ledColor != null) {
        notificationChannel.setLightColor(notificationChannelDetails.ledColor);
      }
      notificationChannel.setShowBadge(BooleanUtils.getValue(notificationChannelDetails.showBadge));
      notificationManager.createNotificationChannel(notificationChannel);
    }
  }

  private static Uri retrieveSoundResourceUri(
      Context context, String sound, SoundSource soundSource) {
    Uri uri = null;
    if (StringUtils.isNullOrEmpty(sound)) {
      uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
    } else {
      // allow null as soundSource was added later and prior to that, it was assumed to be a raw
      // resource
      if (soundSource == null || soundSource == SoundSource.RawResource) {
        uri = Uri.parse("android.resource://" + context.getPackageName() + "/raw/" + sound);
      } else if (soundSource == SoundSource.Uri) {
        uri = Uri.parse(sound);
      }
    }
    return uri;
  }

  private static AlarmManager getAlarmManager(Context context) {
    return (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
  }

  private static boolean isValidDrawableResource(
      Context context, String name, Result result, String errorCode) {
    int resourceId = context.getResources().getIdentifier(name, DRAWABLE, context.getPackageName());
    if (resourceId == 0) {
      result.error(errorCode, String.format(INVALID_DRAWABLE_RESOURCE_ERROR_MESSAGE, name), null);
      return false;
    }
    return true;
  }

  static void showNotification(Context context, NotificationDetails notificationDetails) {
    Notification notification = createNotification(context, notificationDetails);
    NotificationManagerCompat notificationManagerCompat = getNotificationManager(context);

    if (notificationDetails.tag != null) {
      notificationManagerCompat.notify(
          notificationDetails.tag, notificationDetails.id, notification);
    } else {
      notificationManagerCompat.notify(notificationDetails.id, notification);
    }
  }

  static void zonedScheduleNextNotification(
      Context context, NotificationDetails notificationDetails) {
    String nextFireDate = getNextFireDate(notificationDetails);
    if (nextFireDate == null) {
      return;
    }
    notificationDetails.scheduledDateTime = nextFireDate;
    zonedScheduleNotification(context, notificationDetails, true);
  }

  static void zonedScheduleNextNotificationMatchingDateComponents(
      Context context, NotificationDetails notificationDetails) {
    String nextFireDate = getNextFireDateMatchingDateTimeComponents(notificationDetails);
    if (nextFireDate == null) {
      return;
    }
    notificationDetails.scheduledDateTime = nextFireDate;
    zonedScheduleNotification(context, notificationDetails, true);
  }

  static String getNextFireDate(NotificationDetails notificationDetails) {
    if (notificationDetails.scheduledNotificationRepeatFrequency
        == ScheduledNotificationRepeatFrequency.Daily) {
      LocalDateTime localDateTime =
          LocalDateTime.parse(notificationDetails.scheduledDateTime).plusDays(1);
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(localDateTime);
    } else if (notificationDetails.scheduledNotificationRepeatFrequency
        == ScheduledNotificationRepeatFrequency.Weekly) {
      LocalDateTime localDateTime =
          LocalDateTime.parse(notificationDetails.scheduledDateTime).plusWeeks(1);
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(localDateTime);
    }
    return null;
  }

  static String getNextFireDateMatchingDateTimeComponents(NotificationDetails notificationDetails) {
    ZoneId zoneId = ZoneId.of(notificationDetails.timeZoneName);
    ZonedDateTime scheduledDateTime =
        ZonedDateTime.of(LocalDateTime.parse(notificationDetails.scheduledDateTime), zoneId);
    ZonedDateTime now = ZonedDateTime.now(zoneId);
    ZonedDateTime nextFireDate =
        ZonedDateTime.of(
            now.getYear(),
            now.getMonthValue(),
            now.getDayOfMonth(),
            scheduledDateTime.getHour(),
            scheduledDateTime.getMinute(),
            scheduledDateTime.getSecond(),
            scheduledDateTime.getNano(),
            zoneId);
    while (nextFireDate.isBefore(now)) {
      // adjust to be a date in the future that matches the time
      nextFireDate = nextFireDate.plusDays(1);
    }
    if (notificationDetails.matchDateTimeComponents == DateTimeComponents.Time) {
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(nextFireDate);
    } else if (notificationDetails.matchDateTimeComponents == DateTimeComponents.DayOfWeekAndTime) {
      while (nextFireDate.getDayOfWeek() != scheduledDateTime.getDayOfWeek()) {
        nextFireDate = nextFireDate.plusDays(1);
      }
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(nextFireDate);
    } else if (notificationDetails.matchDateTimeComponents
        == DateTimeComponents.DayOfMonthAndTime) {
      while (nextFireDate.getDayOfMonth() != scheduledDateTime.getDayOfMonth()) {
        nextFireDate = nextFireDate.plusDays(1);
      }
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(nextFireDate);
    } else if (notificationDetails.matchDateTimeComponents == DateTimeComponents.DateAndTime) {
      while (nextFireDate.getMonthValue() != scheduledDateTime.getMonthValue()
          || nextFireDate.getDayOfMonth() != scheduledDateTime.getDayOfMonth()) {
        nextFireDate = nextFireDate.plusDays(1);
      }
      return DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(nextFireDate);
    }
    return null;
  }

  private static NotificationManagerCompat getNotificationManager(Context context) {
    return NotificationManagerCompat.from(context);
  }

  private static boolean launchedActivityFromHistory(Intent intent) {
    return intent != null
        && (intent.getFlags() & Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY)
            == Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY;
  }

  private void setActivity(Activity flutterActivity) {
    this.mainActivity = flutterActivity;
  }

  private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
    this.applicationContext = context;
    this.channel = new MethodChannel(binaryMessenger, METHOD_CHANNEL);
    this.channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.channel.setMethodCallHandler(null);
    this.channel = null;
    this.applicationContext = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    binding.addRequestPermissionsResultListener(this);
    mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.mainActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    binding.addRequestPermissionsResultListener(this);
    mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.mainActivity = null;
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case INITIALIZE_METHOD:
        initialize(call, result);
        break;
      case GET_CALLBACK_HANDLE_METHOD:
        getCallbackHandle(result);
        break;
      case GET_NOTIFICATION_APP_LAUNCH_DETAILS_METHOD:
        getNotificationAppLaunchDetails(result);
        break;
      case SHOW_METHOD:
        show(call, result);
        break;
      case SCHEDULE_METHOD:
        schedule(call, result);
        break;
      case ZONED_SCHEDULE_METHOD:
        zonedSchedule(call, result);
        break;
      case REQUEST_PERMISSION_METHOD:
        requestPermission(
            new PermissionRequestListener() {
              @Override
              public void complete(boolean granted) {
                result.success(granted);
              }

              @Override
              public void fail(String message) {
                result.error(PERMISSION_REQUEST_IN_PROGRESS_ERROR_CODE, message, null);
              }
            });
        break;
      case PERIODICALLY_SHOW_METHOD:
      case SHOW_DAILY_AT_TIME_METHOD:
      case SHOW_WEEKLY_AT_DAY_AND_TIME_METHOD:
        repeat(call, result);
        break;
      case CANCEL_METHOD:
        cancel(call, result);
        break;
      case CANCEL_ALL_METHOD:
        cancelAllNotifications(result);
        break;
      case PENDING_NOTIFICATION_REQUESTS_METHOD:
        pendingNotificationRequests(result);
        break;
      case ARE_NOTIFICATIONS_ENABLED_METHOD:
        areNotificationsEnabled(result);
        break;
      case CREATE_NOTIFICATION_CHANNEL_GROUP_METHOD:
        createNotificationChannelGroup(call, result);
        break;
      case DELETE_NOTIFICATION_CHANNEL_GROUP_METHOD:
        deleteNotificationChannelGroup(call, result);
        break;
      case CREATE_NOTIFICATION_CHANNEL_METHOD:
        createNotificationChannel(call, result);
        break;
      case DELETE_NOTIFICATION_CHANNEL_METHOD:
        deleteNotificationChannel(call, result);
        break;
      case GET_ACTIVE_NOTIFICATIONS_METHOD:
        getActiveNotifications(result);
        break;
      case GET_ACTIVE_NOTIFICATION_MESSAGING_STYLE_METHOD:
        getActiveNotificationMessagingStyle(call, result);
        break;
      case GET_NOTIFICATION_CHANNELS_METHOD:
        getNotificationChannels(result);
        break;
      case START_FOREGROUND_SERVICE:
        startForegroundService(call, result);
        break;
      case STOP_FOREGROUND_SERVICE:
        stopForegroundService(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void pendingNotificationRequests(Result result) {
    ArrayList<NotificationDetails> scheduledNotifications =
        loadScheduledNotifications(applicationContext);
    List<Map<String, Object>> pendingNotifications = new ArrayList<>();

    for (NotificationDetails scheduledNotification : scheduledNotifications) {
      HashMap<String, Object> pendingNotification = new HashMap<>();
      pendingNotification.put("id", scheduledNotification.id);
      pendingNotification.put("title", scheduledNotification.title);
      pendingNotification.put("body", scheduledNotification.body);
      pendingNotification.put("payload", scheduledNotification.payload);
      pendingNotifications.add(pendingNotification);
    }
    result.success(pendingNotifications);
  }

  private void getActiveNotifications(Result result) {
    if (VERSION.SDK_INT < VERSION_CODES.M) {
      result.error(UNSUPPORTED_OS_VERSION_ERROR_CODE, GET_ACTIVE_NOTIFICATIONS_ERROR_MESSAGE, null);
      return;
    }
    NotificationManager notificationManager =
        (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
    try {
      StatusBarNotification[] activeNotifications = notificationManager.getActiveNotifications();
      List<Map<String, Object>> activeNotificationsPayload = new ArrayList<>();

      for (StatusBarNotification activeNotification : activeNotifications) {
        HashMap<String, Object> activeNotificationPayload = new HashMap<>();
        activeNotificationPayload.put("id", activeNotification.getId());
        Notification notification = activeNotification.getNotification();
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
          activeNotificationPayload.put("channelId", notification.getChannelId());
        }

        activeNotificationPayload.put("tag", activeNotification.getTag());
        activeNotificationPayload.put("groupKey", notification.getGroup());
        activeNotificationPayload.put(
            "title", notification.extras.getCharSequence("android.title"));
        activeNotificationPayload.put("body", notification.extras.getCharSequence("android.text"));
        activeNotificationsPayload.add(activeNotificationPayload);
      }
      result.success(activeNotificationsPayload);
    } catch (Throwable e) {
      result.error(UNSUPPORTED_OS_VERSION_ERROR_CODE, e.getMessage(), e.getStackTrace());
    }
  }

  private void cancel(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    Integer id = (Integer) arguments.get(CANCEL_ID);
    String tag = (String) arguments.get(CANCEL_TAG);
    cancelNotification(id, tag);
    result.success(null);
  }

  private void repeat(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
    if (notificationDetails != null) {
      repeatNotification(applicationContext, notificationDetails, true);
      result.success(null);
    }
  }

  private void schedule(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
    if (notificationDetails != null) {
      scheduleNotification(applicationContext, notificationDetails, true);
      result.success(null);
    }
  }

  private void zonedSchedule(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
    if (notificationDetails != null) {
      if (notificationDetails.matchDateTimeComponents != null) {
        notificationDetails.scheduledDateTime =
            getNextFireDateMatchingDateTimeComponents(notificationDetails);
      }
      zonedScheduleNotification(applicationContext, notificationDetails, true);
      result.success(null);
    }
  }

  private void show(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    NotificationDetails notificationDetails = extractNotificationDetails(result, arguments);
    if (notificationDetails != null) {
      showNotification(applicationContext, notificationDetails);
      result.success(null);
    }
  }

  private void getNotificationAppLaunchDetails(Result result) {
    Map<String, Object> notificationAppLaunchDetails = new HashMap<>();
    Boolean notificationLaunchedApp = false;
    if (mainActivity != null) {
      Intent launchIntent = mainActivity.getIntent();
      notificationLaunchedApp =
          launchIntent != null
              && (SELECT_NOTIFICATION.equals(launchIntent.getAction())
                  || SELECT_FOREGROUND_NOTIFICATION_ACTION.equals(launchIntent.getAction()))
              && !launchedActivityFromHistory(launchIntent);
      if (notificationLaunchedApp) {
        notificationAppLaunchDetails.put(
            "notificationResponse", extractNotificationResponseMap(launchIntent));
      }
    }

    notificationAppLaunchDetails.put(NOTIFICATION_LAUNCHED_APP, notificationLaunchedApp);
    result.success(notificationAppLaunchDetails);
  }

  private void initialize(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    String defaultIcon = (String) arguments.get(DEFAULT_ICON);
    if (!isValidDrawableResource(
        applicationContext, defaultIcon, result, INVALID_ICON_ERROR_CODE)) {
      return;
    }

    Long dispatcherHandle = call.argument(DISPATCHER_HANDLE);
    Long callbackHandle = call.argument(CALLBACK_HANDLE);
    if (dispatcherHandle != null && callbackHandle != null) {
      new IsolatePreferences(applicationContext).saveCallbackKeys(dispatcherHandle, callbackHandle);
    }

    SharedPreferences sharedPreferences =
        applicationContext.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = sharedPreferences.edit();
    editor.putString(DEFAULT_ICON, defaultIcon).apply();
    result.success(true);
  }

  private void getCallbackHandle(Result result) {
    final Long handle = new IsolatePreferences(applicationContext).getCallbackHandle();
    result.success(handle);
  }

  /// Extracts the details of the notifications passed from the Flutter side and also validates that
  // some of the details (especially resources) passed are valid
  private NotificationDetails extractNotificationDetails(
      Result result, Map<String, Object> arguments) {
    NotificationDetails notificationDetails = NotificationDetails.from(arguments);
    if (hasInvalidIcon(result, notificationDetails.icon)
        || hasInvalidLargeIcon(
            result, notificationDetails.largeIcon, notificationDetails.largeIconBitmapSource)
        || hasInvalidBigPictureResources(result, notificationDetails)
        || hasInvalidRawSoundResource(result, notificationDetails)
        || hasInvalidLedDetails(result, notificationDetails)) {
      return null;
    }

    return notificationDetails;
  }

  private boolean hasInvalidLedDetails(Result result, NotificationDetails notificationDetails) {
    if (notificationDetails.ledColor != null
        && (notificationDetails.ledOnMs == null || notificationDetails.ledOffMs == null)) {
      result.error(INVALID_LED_DETAILS_ERROR_CODE, INVALID_LED_DETAILS_ERROR_MESSAGE, null);
      return true;
    }
    return false;
  }

  private boolean hasInvalidRawSoundResource(
      Result result, NotificationDetails notificationDetails) {
    if (!StringUtils.isNullOrEmpty(notificationDetails.sound)
        && (notificationDetails.soundSource == null
            || notificationDetails.soundSource == SoundSource.RawResource)) {
      int soundResourceId =
          applicationContext
              .getResources()
              .getIdentifier(notificationDetails.sound, "raw", applicationContext.getPackageName());
      if (soundResourceId == 0) {
        result.error(
            INVALID_SOUND_ERROR_CODE,
            String.format(INVALID_RAW_RESOURCE_ERROR_MESSAGE, notificationDetails.sound),
            null);
        return true;
      }
    }
    return false;
  }

  private boolean hasInvalidBigPictureResources(
      Result result, NotificationDetails notificationDetails) {
    if (notificationDetails.style == NotificationStyle.BigPicture) {
      BigPictureStyleInformation bigPictureStyleInformation =
          (BigPictureStyleInformation) notificationDetails.styleInformation;
      if (hasInvalidLargeIcon(
          result,
          bigPictureStyleInformation.largeIcon,
          bigPictureStyleInformation.largeIconBitmapSource)) return true;

      if (bigPictureStyleInformation.bigPictureBitmapSource == BitmapSource.DrawableResource) {
        String bigPictureResourceName = (String) bigPictureStyleInformation.bigPicture;
        return StringUtils.isNullOrEmpty(bigPictureResourceName)
            && !isValidDrawableResource(
                applicationContext, bigPictureResourceName, result, INVALID_BIG_PICTURE_ERROR_CODE);
      } else if (bigPictureStyleInformation.bigPictureBitmapSource == BitmapSource.FilePath) {
        String largeIconPath = (String) bigPictureStyleInformation.bigPicture;
        return StringUtils.isNullOrEmpty(largeIconPath);
      } else if (bigPictureStyleInformation.bigPictureBitmapSource == BitmapSource.ByteArray) {
        byte[] byteArray = (byte[]) bigPictureStyleInformation.bigPicture;
        return byteArray == null || byteArray.length == 0;
      }
    }
    return false;
  }

  private boolean hasInvalidLargeIcon(
      Result result, Object largeIcon, BitmapSource largeIconBitmapSource) {
    if (largeIconBitmapSource == BitmapSource.DrawableResource
        || largeIconBitmapSource == BitmapSource.FilePath) {
      String largeIconPath = (String) largeIcon;
      return !StringUtils.isNullOrEmpty(largeIconPath)
          && largeIconBitmapSource == BitmapSource.DrawableResource
          && !isValidDrawableResource(
              applicationContext, largeIconPath, result, INVALID_LARGE_ICON_ERROR_CODE);
    } else if (largeIconBitmapSource == BitmapSource.ByteArray) {
      byte[] byteArray = (byte[]) largeIcon;
      return byteArray.length == 0;
    }
    return false;
  }

  private boolean hasInvalidIcon(Result result, String icon) {
    return !StringUtils.isNullOrEmpty(icon)
        && !isValidDrawableResource(applicationContext, icon, result, INVALID_ICON_ERROR_CODE);
  }

  private void cancelNotification(Integer id, String tag) {
    Intent intent = new Intent(applicationContext, ScheduledNotificationReceiver.class);
    PendingIntent pendingIntent = getBroadcastPendingIntent(applicationContext, id, intent);
    AlarmManager alarmManager = getAlarmManager(applicationContext);
    alarmManager.cancel(pendingIntent);
    NotificationManagerCompat notificationManager = getNotificationManager(applicationContext);
    if (tag == null) {
      notificationManager.cancel(id);
    } else {
      notificationManager.cancel(tag, id);
    }
    removeNotificationFromCache(applicationContext, id);
  }

  private void cancelAllNotifications(Result result) {
    NotificationManagerCompat notificationManager = getNotificationManager(applicationContext);
    notificationManager.cancelAll();
    ArrayList<NotificationDetails> scheduledNotifications =
        loadScheduledNotifications(applicationContext);
    if (scheduledNotifications == null || scheduledNotifications.isEmpty()) {
      result.success(null);
      return;
    }

    Intent intent = new Intent(applicationContext, ScheduledNotificationReceiver.class);
    for (NotificationDetails scheduledNotification : scheduledNotifications) {
      PendingIntent pendingIntent =
          getBroadcastPendingIntent(applicationContext, scheduledNotification.id, intent);
      AlarmManager alarmManager = getAlarmManager(applicationContext);
      alarmManager.cancel(pendingIntent);
    }

    saveScheduledNotifications(applicationContext, new ArrayList<>());
    result.success(null);
  }

  public void requestPermission(@NonNull PermissionRequestListener callback) {
    if (permissionRequestInProgress) {
      callback.fail("Another permission request is already in progress");
      return;
    }

    this.callback = callback;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      String permission = Manifest.permission.POST_NOTIFICATIONS;
      boolean permissionGranted =
          ContextCompat.checkSelfPermission(mainActivity, permission)
              == PackageManager.PERMISSION_GRANTED;

      if (!permissionGranted) {
        permissionRequestInProgress = true;
        ActivityCompat.requestPermissions(
            mainActivity, new String[] {permission}, NOTIFICATION_PERMISSION_REQUEST_CODE);
      } else {
        this.callback.complete(true);
        permissionRequestInProgress = false;
      }
    } else {
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(mainActivity);
      this.callback.complete(notificationManager.areNotificationsEnabled());
    }
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (permissionRequestInProgress && requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
      boolean granted =
          grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
      callback.complete(granted);
      permissionRequestInProgress = false;
      return granted;
    } else {
      return false;
    }
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    boolean res = sendNotificationPayloadMessage(intent);
    if (res && mainActivity != null) {
      mainActivity.setIntent(intent);
    }
    return res;
  }

  private Boolean sendNotificationPayloadMessage(Intent intent) {
    if (SELECT_NOTIFICATION.equals(intent.getAction())
        || SELECT_FOREGROUND_NOTIFICATION_ACTION.equals(intent.getAction())) {
      Map<String, Object> notificationResponse = extractNotificationResponseMap(intent);
      if (SELECT_FOREGROUND_NOTIFICATION_ACTION.equals(intent.getAction())) {
        if (intent.getBooleanExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, false)) {
          NotificationManagerCompat.from(applicationContext)
              .cancel(
                  (int) notificationResponse.get(FlutterLocalNotificationsPlugin.NOTIFICATION_ID));
        }
      }
      channel.invokeMethod("didReceiveNotificationResponse", notificationResponse);
      return true;
    }

    return false;
  }

  private void createNotificationChannelGroup(MethodCall call, Result result) {
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      Map<String, Object> arguments = call.arguments();
      NotificationChannelGroupDetails notificationChannelGroupDetails =
          NotificationChannelGroupDetails.from(arguments);
      NotificationManager notificationManager =
          (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
      NotificationChannelGroup notificationChannelGroup =
          new NotificationChannelGroup(
              notificationChannelGroupDetails.id, notificationChannelGroupDetails.name);
      if (VERSION.SDK_INT >= VERSION_CODES.P) {
        notificationChannelGroup.setDescription(notificationChannelGroupDetails.description);
      }
      notificationManager.createNotificationChannelGroup(notificationChannelGroup);
    }
    result.success(null);
  }

  private void deleteNotificationChannelGroup(MethodCall call, Result result) {
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      NotificationManager notificationManager =
          (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
      String groupId = call.arguments();
      notificationManager.deleteNotificationChannelGroup(groupId);
    }
    result.success(null);
  }

  private void createNotificationChannel(MethodCall call, Result result) {
    Map<String, Object> arguments = call.arguments();
    NotificationChannelDetails notificationChannelDetails =
        NotificationChannelDetails.from(arguments);
    setupNotificationChannel(applicationContext, notificationChannelDetails);
    result.success(null);
  }

  private void deleteNotificationChannel(MethodCall call, Result result) {
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      NotificationManager notificationManager =
          (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
      String channelId = call.arguments();
      notificationManager.deleteNotificationChannel(channelId);
    }
    result.success(null);
  }

  private void getActiveNotificationMessagingStyle(MethodCall call, Result result) {
    if (VERSION.SDK_INT < VERSION_CODES.M) {
      result.error(
          UNSUPPORTED_OS_VERSION_ERROR_CODE,
          "Android version must be 6.0 or newer to use getActiveNotificationMessagingStyle",
          null);
      return;
    }
    NotificationManager notificationManager =
        (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
    try {
      Map<String, Object> arguments = call.arguments();
      int id = (int) arguments.get("id");
      String tag = (String) arguments.get("tag");

      StatusBarNotification[] activeNotifications = notificationManager.getActiveNotifications();
      Notification notification = null;
      for (StatusBarNotification activeNotification : activeNotifications) {
        if (activeNotification.getId() == id
            && (tag == null || tag.equals(activeNotification.getTag()))) {
          notification = activeNotification.getNotification();
          break;
        }
      }

      if (notification == null) {
        result.success(null);
        return;
      }

      NotificationCompat.MessagingStyle messagingStyle =
          NotificationCompat.MessagingStyle.extractMessagingStyleFromNotification(notification);
      if (messagingStyle == null) {
        result.success(null);
        return;
      }

      HashMap<String, Object> stylePayload = new HashMap<>();
      stylePayload.put("groupConversation", messagingStyle.isGroupConversation());
      stylePayload.put("person", describePerson(messagingStyle.getUser()));
      stylePayload.put("conversationTitle", messagingStyle.getConversationTitle());

      List<Map<String, Object>> messagesPayload = new ArrayList<>();
      for (NotificationCompat.MessagingStyle.Message msg : messagingStyle.getMessages()) {
        Map<String, Object> msgPayload = new HashMap<>();
        msgPayload.put("text", msg.getText());
        msgPayload.put("timestamp", msg.getTimestamp());
        msgPayload.put("person", describePerson(msg.getPerson()));
        messagesPayload.add(msgPayload);
      }
      stylePayload.put("messages", messagesPayload);

      result.success(stylePayload);
    } catch (Throwable e) {
      result.error(
          GET_ACTIVE_NOTIFICATION_MESSAGING_STYLE_ERROR_CODE, e.getMessage(), e.getStackTrace());
    }
  }

  private Map<String, Object> describePerson(Person person) {
    if (person == null) {
      return null;
    }
    Map<String, Object> payload = new HashMap<>();
    payload.put("key", person.getKey());
    payload.put("name", person.getName());
    payload.put("uri", person.getUri());
    payload.put("bot", person.isBot());
    payload.put("important", person.isImportant());
    payload.put("icon", describeIcon(person.getIcon()));
    return payload;
  }

  private Map<String, Object> describeIcon(IconCompat icon) {
    if (icon == null) {
      return null;
    }
    IconSource source;
    Object data;
    switch (icon.getType()) {
      case IconCompat.TYPE_RESOURCE:
        source = IconSource.DrawableResource;
        int resId = icon.getResId();
        Context context = applicationContext;
        assert (context.getResources().getResourceTypeName(resId).equals(DRAWABLE));
        assert (context
            .getResources()
            .getResourcePackageName(resId)
            .equals(context.getPackageName()));
        data = context.getResources().getResourceEntryName(resId);
        break;
      case IconCompat.TYPE_URI:
        source = IconSource.ContentUri;
        data = icon.getUri().toString();
        break;
      default:
        return null;
    }
    Map<String, Object> payload = new HashMap<>();
    payload.put("source", source.ordinal());
    payload.put("data", data);
    return payload;
  }

  private void getNotificationChannels(Result result) {
    try {
      NotificationManagerCompat notificationManagerCompat =
          getNotificationManager(applicationContext);
      List<NotificationChannel> channels = notificationManagerCompat.getNotificationChannels();
      List<Map<String, Object>> channelsPayload = new ArrayList<>();
      for (NotificationChannel channel : channels) {
        HashMap<String, Object> channelPayload = getMappedNotificationChannel(channel);
        channelsPayload.add(channelPayload);
      }
      result.success(channelsPayload);
    } catch (Throwable e) {
      result.error(GET_NOTIFICATION_CHANNELS_ERROR_CODE, e.getMessage(), e.getStackTrace());
    }
  }

  private HashMap<String, Object> getMappedNotificationChannel(NotificationChannel channel) {
    HashMap<String, Object> channelPayload = new HashMap<>();
    if (VERSION.SDK_INT >= VERSION_CODES.O) {
      channelPayload.put("id", channel.getId());
      channelPayload.put("name", channel.getName());
      channelPayload.put("description", channel.getDescription());
      channelPayload.put("groupId", channel.getGroup());
      channelPayload.put("showBadge", channel.canShowBadge());
      channelPayload.put("importance", channel.getImportance());
      Uri soundUri = channel.getSound();
      if (soundUri == null) {
        channelPayload.put("sound", null);
        channelPayload.put("playSound", false);
      } else {
        channelPayload.put("playSound", true);
        List<SoundSource> soundSources = Arrays.asList(SoundSource.values());
        if (soundUri.getScheme().equals("android.resource")) {
          String[] splitUri = soundUri.toString().split("/");
          String resource = splitUri[splitUri.length - 1];
          Integer resourceId = tryParseInt(resource);
          if (resourceId == null) {
            channelPayload.put("soundSource", soundSources.indexOf(SoundSource.RawResource));
            channelPayload.put("sound", resource);
          } else {
            // Kept for backwards compatibility when the source resource used to be based on id
            String resourceName =
                applicationContext.getResources().getResourceEntryName(resourceId);
            if (resourceName != null) {
              channelPayload.put("soundSource", soundSources.indexOf(SoundSource.RawResource));
              channelPayload.put("sound", resourceName);
            }
          }
        } else {
          channelPayload.put("soundSource", soundSources.indexOf(SoundSource.Uri));
          channelPayload.put("sound", soundUri.toString());
        }
      }
      channelPayload.put("enableVibration", channel.shouldVibrate());
      channelPayload.put("vibrationPattern", channel.getVibrationPattern());
      channelPayload.put("enableLights", channel.shouldShowLights());
      channelPayload.put("ledColor", channel.getLightColor());
    }
    return channelPayload;
  }

  private Integer tryParseInt(String value) {
    try {
      return Integer.parseInt(value);
    } catch (NumberFormatException e) {
      return null;
    }
  }

  private void startForegroundService(MethodCall call, Result result) {
    Map<String, Object> notificationData = call.argument("notificationData");
    Integer startType = call.<Integer>argument("startType");
    ArrayList<Integer> foregroundServiceTypes = call.argument("foregroundServiceTypes");
    if (foregroundServiceTypes == null || foregroundServiceTypes.size() != 0) {
      if (notificationData != null && startType != null) {
        NotificationDetails notificationDetails =
            extractNotificationDetails(result, notificationData);
        if (notificationDetails != null) {
          if (notificationDetails.id != 0) {
            ForegroundServiceStartParameter parameter =
                new ForegroundServiceStartParameter(
                    notificationDetails, startType, foregroundServiceTypes);
            Intent intent = new Intent(applicationContext, ForegroundService.class);
            intent.putExtra(ForegroundServiceStartParameter.EXTRA, parameter);
            ContextCompat.startForegroundService(applicationContext, intent);
            result.success(null);
          } else {
            result.error(
                "ARGUMENT_ERROR",
                "The id of the notification for a foreground service must not be 0!",
                null);
          }
        }
      } else {
        result.error(
            "ARGUMENT_ERROR", "An argument passed to startForegroundService was null!", null);
      }
    } else {
      result.error(
          "ARGUMENT_ERROR", "If foregroundServiceTypes is non-null it must not be empty!", null);
    }
  }

  private void stopForegroundService(Result result) {
    applicationContext.stopService(new Intent(applicationContext, ForegroundService.class));
    result.success(null);
  }

  private void areNotificationsEnabled(Result result) {
    NotificationManagerCompat notificationManager = getNotificationManager(applicationContext);
    result.success(notificationManager.areNotificationsEnabled());
  }
}
