package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.Nullable;
import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;

public class ActionBroadcastReceiver extends BroadcastReceiver {

	private static final String TAG = "ActionBroadcastReceiver";

	@Nullable
	private static FlutterEngine engine;

	@Override
	public void onReceive(Context context, Intent intent) {
		Log.d(TAG, "Received a intent: " + intent.getAction());
		final String name = intent.getStringExtra("name");

		Log.d(TAG, "Received a intent: " + name);
		startEngine(context);
	}

	private void startEngine(Context context) {
		long dispatcherHandle = IsolatePreferences.getCallbackDispatcherHandle(context);

		Log.d(TAG, "dispatcherHandle: " + dispatcherHandle);

		if (dispatcherHandle != -1L && engine == null) {
			engine = new FlutterEngine(context);
			FlutterMain.ensureInitializationComplete(context, null);

			FlutterCallbackInformation callbackInfo =
					FlutterCallbackInformation.lookupCallbackInformation(dispatcherHandle);
			String dartBundlePath = FlutterMain.findAppBundlePath();

			engine
					.getDartExecutor()
					.executeDartCallback(
							new DartExecutor.DartCallback(context.getAssets(), dartBundlePath, callbackInfo));
		}
	}

}
