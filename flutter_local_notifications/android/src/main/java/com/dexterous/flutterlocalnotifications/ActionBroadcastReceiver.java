package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.core.app.RemoteInput;
import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActionBroadcastReceiver extends BroadcastReceiver {
	public static final String ACTION_TAPPED = "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver.ACTION_TAPPED";

	@Nullable
	private static ActionEventSink actionEventSink;

	@Nullable
	private static FlutterEngine engine;

	@Override
	public void onReceive(Context context, Intent intent) {
		final String id = intent.getStringExtra("id");

		final Map<String, Object> action = new HashMap<>();
		action.put("id", id);

		Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
		if (remoteInput != null) {
			action.put("input", remoteInput.getString("FlutterLocalNotificationsPluginInputResult"));
		} else {
			action.put("input", "");
		}

		if (actionEventSink == null) {
			actionEventSink = new ActionEventSink();
		}
		actionEventSink.addItem(action);

		startEngine(context);
	}

	private static class ActionEventSink implements StreamHandler {

		final List<Map<String, Object>> cache = new ArrayList<>();

		@Nullable
		private EventSink eventSink;

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
		long dispatcherHandle = IsolatePreferences.getCallbackDispatcherHandle(context);

		if (dispatcherHandle != -1L && engine == null) {
			engine = new FlutterEngine(context);
			FlutterMain.ensureInitializationComplete(context, null);

			FlutterCallbackInformation callbackInfo =
					FlutterCallbackInformation.lookupCallbackInformation(dispatcherHandle);
			String dartBundlePath = FlutterMain.findAppBundlePath();

			EventChannel channel = new EventChannel(
					engine.getDartExecutor().getBinaryMessenger(),
					"dexterous.com/flutter/local_notifications/actions");

			channel.setStreamHandler(actionEventSink);

			engine
					.getDartExecutor()
					.executeDartCallback(
							new DartExecutor.DartCallback(context.getAssets(), dartBundlePath, callbackInfo));
		}
	}

}
