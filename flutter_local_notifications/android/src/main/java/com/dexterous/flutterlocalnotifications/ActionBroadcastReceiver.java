package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.view.FlutterCallbackInformation;

public class ActionBroadcastReceiver extends BroadcastReceiver {
  public static final String ACTION_TAPPED =
      "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver.ACTION_TAPPED";
  private static final String TAG = "ActionBroadcastReceiver";
  @Nullable private static ActionEventSink actionEventSink;
  @Nullable private static FlutterEngine engine;
  IsolatePreferences preferences;

  @VisibleForTesting
  ActionBroadcastReceiver(IsolatePreferences preferences) {
    this.preferences = preferences;
  }

  @Keep
  public ActionBroadcastReceiver() {}

  @Override
  public void onReceive(Context context, Intent intent) {
    if (!ACTION_TAPPED.equalsIgnoreCase(intent.getAction())) {
      return;
    }

    preferences = preferences == null ? new IsolatePreferences(context) : preferences;

    final Map<String, Object> action =
        FlutterLocalNotificationsPlugin.extractNotificationResponseMap(intent);

    if (intent.getBooleanExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, false)) {
      int notificationId = (int) action.get(FlutterLocalNotificationsPlugin.NOTIFICATION_ID);
      Object tag = action.get(FlutterLocalNotificationsPlugin.NOTIFICATION_TAG);

      if (tag instanceof String) {
        NotificationManagerCompat.from(context).cancel((String) tag, notificationId);
      } else {
        NotificationManagerCompat.from(context).cancel(notificationId);
      }
    }

    if (actionEventSink == null) {
      actionEventSink = new ActionEventSink();
    }
    actionEventSink.addItem(action);

    startEngine(context);
  }

  private void startEngine(Context context) {
    if (engine != null) {
      Log.e(TAG, "Engine is already initialised");
      return;
    }

    FlutterInjector injector = FlutterInjector.instance();
    FlutterLoader loader = injector.flutterLoader();

    loader.startInitialization(context);
    loader.ensureInitializationComplete(context, null);

    engine = new FlutterEngine(context);

    /// This lookup needs to be done after creating an instance of `FlutterEngine` or lookup may
    // fail
    FlutterCallbackInformation dispatcherHandle = preferences.lookupDispatcherHandle();
    if (dispatcherHandle == null) {
      Log.w(TAG, "Callback information could not be retrieved");
      return;
    }

    DartExecutor dartExecutor = engine.getDartExecutor();

    initializeEventChannel(dartExecutor);

    String dartBundlePath = loader.findAppBundlePath();
    dartExecutor.executeDartCallback(
        new DartExecutor.DartCallback(context.getAssets(), dartBundlePath, dispatcherHandle));
  }

  private void initializeEventChannel(DartExecutor dartExecutor) {
    EventChannel channel =
        new EventChannel(
            dartExecutor.getBinaryMessenger(), "dexterous.com/flutter/local_notifications/actions");
    channel.setStreamHandler(actionEventSink);
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
}
