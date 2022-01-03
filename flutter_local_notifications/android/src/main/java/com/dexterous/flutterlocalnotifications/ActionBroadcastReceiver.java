package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.RemoteInput;
import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.view.FlutterCallbackInformation;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActionBroadcastReceiver extends BroadcastReceiver {
  @VisibleForTesting
  ActionBroadcastReceiver(IsolatePreferences preferences) {
    this.preferences = preferences;
  }

  @Keep
  public ActionBroadcastReceiver() {}

  IsolatePreferences preferences;

  public static final String ACTION_TAPPED =
      "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver.ACTION_TAPPED";
  public static final String ACTION_ID = "actionId";
  public static final String NOTIFICATION_ID = "notificationId";
  private static final String INPUT = "input";

  public static final String INPUT_RESULT = "FlutterLocalNotificationsPluginInputResult";

  @Nullable private static ActionEventSink actionEventSink;

  @Nullable private static FlutterEngine engine;

  @Override
  public void onReceive(Context context, Intent intent) {
    if (!ACTION_TAPPED.equalsIgnoreCase(intent.getAction())) {
      return;
    }

    preferences = preferences == null ? new IsolatePreferences(context) : preferences;

    final Map<String, Object> action = new HashMap<>();
    final int notificationId = intent.getIntExtra(NOTIFICATION_ID, -1);
    action.put(NOTIFICATION_ID, notificationId);
    action.put(
        ACTION_ID, intent.hasExtra(ACTION_ID) ? intent.getStringExtra(ACTION_ID) : "unknown");
    action.put(
        FlutterLocalNotificationsPlugin.PAYLOAD,
        intent.hasExtra(FlutterLocalNotificationsPlugin.PAYLOAD)
            ? intent.getStringExtra(FlutterLocalNotificationsPlugin.PAYLOAD)
            : "");

    Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
    if (remoteInput != null) {
      action.put(INPUT, remoteInput.getString(INPUT_RESULT));
    } else {
      action.put(INPUT, "");
    }

    if (intent.getBooleanExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, false)) {
      NotificationManagerCompat.from(context).cancel(notificationId);
    }

    if (actionEventSink == null) {
      actionEventSink = new ActionEventSink();
    }
    actionEventSink.addItem(action);

    startEngine(context);
  }

  private static class ActionEventSink implements StreamHandler {

    final List<Map<String, Object>> cache = new ArrayList<>();

    @Nullable private EventSink eventSink;

    public void addItem(Map<String, Object> item) {
      if (eventSink != null) {
        eventSink.success(item);
      } else {
        cache.add(item);
      }
    }

    @Override
    public void onListen(Object arguments, EventSink events) {
      for (Map<String, Object> item : cache) {
        events.success(item);
      }

      cache.clear();
      eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
      eventSink = null;
    }
  }

  private void startEngine(Context context) {
    FlutterCallbackInformation dispatcherHandle = preferences.lookupDispatcherHandle();

    if (dispatcherHandle != null && engine == null) {
      FlutterInjector injector = FlutterInjector.instance();
      FlutterLoader loader = injector.flutterLoader();

      loader.startInitialization(context);
      loader.ensureInitializationComplete(context, null);

      engine = new FlutterEngine(context);

      String dartBundlePath = loader.findAppBundlePath();

      EventChannel channel =
          new EventChannel(
              engine.getDartExecutor().getBinaryMessenger(),
              "dexterous.com/flutter/local_notifications/actions");

      channel.setStreamHandler(actionEventSink);

      engine
          .getDartExecutor()
          .executeDartCallback(
              new DartExecutor.DartCallback(context.getAssets(), dartBundlePath, dispatcherHandle));
    }
  }
}
