package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import androidx.core.app.NotificationManagerCompat;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;

public class NotificationActionReceiver extends BroadcastReceiver implements MethodChannel.MethodCallHandler {
    private static final String TAG = "NotifActionReceiver"; // 23 char limit

    private static final String METHOD_CHANNEL = "dexterous.com/flutter/local_notifications_background";
    private static final String INITIALIZED_METHOD = "initialized";
    private static final String ENQUEUE_METHOD = "enqueue";

    // Queue for notification actions waiting to be processed (sent to listeners on the Flutter side)
    // Required for the case when there are actions before the background isolate needed for notifying
    // the Flutter side is ready.
    private Queue<IncomingAction> incomingActions = new LinkedList<>();

    private boolean initialized = false;
    private FlutterNativeView flutterNativeView;
    private MethodChannel methodChannel;
    private NotificationManagerCompat notificationManagerCompat;

    @Override
    public void onReceive(Context context, Intent intent) {
        FlutterMain.ensureInitializationComplete(context, null);

        String notificationActionId = intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ACTION_ID);

        String notificationDetailsJson = intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_DETAILS);
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        Type type = new TypeToken<NotificationDetails>() {
        }.getType();
        NotificationDetails notificationDetails = gson.fromJson(notificationDetailsJson, type);

        Log.i(TAG, "NotificationActionReceiver received: " + notificationDetailsJson);

        BroadcastReceiver.PendingResult broadcastReceiverResult = goAsync();
        incomingActions.add(new IncomingAction(notificationActionId, notificationDetails, broadcastReceiverResult));

        if (initialized) {
            processActions();
        } else {
            notificationManagerCompat = NotificationManagerCompat.from(context);

            flutterNativeView = new FlutterNativeView(context, true);

            runSetupActionQueueCallback(context, flutterNativeView);

            FlutterLocalNotificationsPlugin.pluginRegistrantCallback.registerWith(flutterNativeView.getPluginRegistry());

            methodChannel = new MethodChannel(flutterNativeView, METHOD_CHANNEL);
            methodChannel.setMethodCallHandler(this);
        }
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (!call.method.equals(INITIALIZED_METHOD)) {
            Log.e(TAG, "Unexpected call method: " + call.method);
            result.notImplemented();
        }
        initialized = true;
        processActions();
    }

    private void processActions() {
        while(!incomingActions.isEmpty()) {
            final IncomingAction incomingAction = incomingActions.remove();
            final Map<String, Object> actionData = new HashMap<String, Object>() {{
                put("categoryIdentifier", incomingAction.notificationDetails.categoryIdentifier);
                put("actionIdentifier", incomingAction.notificationActionId);
                put("payload", incomingAction.notificationDetails.payload);
            }};
            methodChannel.invokeMethod(ENQUEUE_METHOD, actionData, new MethodChannel.Result() {
                @Override
                public void success(Object result) {
                    Log.i(TAG, "Success processing enqueue!");
                    flutterNativeView.destroy();
                    notificationManagerCompat.cancel(incomingAction.notificationDetails.id);
                    incomingAction.result.finish();
                }

                @Override
                public void error(String errorCode, String errorMessage, Object o) {
                    Log.e(TAG, "Error during `enqueue': " + errorCode + " / " + errorMessage);
                    flutterNativeView.destroy();
                    notificationManagerCompat.cancel(incomingAction.notificationDetails.id);
                    incomingAction.result.finish();
                }

                @Override
                public void notImplemented() {
                    Log.e(TAG, "Unexpectedly unimplemented `enqueue' method");
                    flutterNativeView.destroy();
                    notificationManagerCompat.cancel(incomingAction.notificationDetails.id);
                    incomingAction.result.finish();
                }
            });
        }
    }

    private void runSetupActionQueueCallback(Context context, FlutterNativeView flutterNativeView) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(
                FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_CACHE_NAME, Context.MODE_PRIVATE);
        long callbackId = sharedPreferences.getLong(
                FlutterLocalNotificationsPlugin.SETUP_ACTION_QUEUE_CALLBACK_KEY, 0);
        FlutterCallbackInformation callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackId);
        FlutterRunArguments flutterRunArguments = new FlutterRunArguments();
        flutterRunArguments.bundlePath = FlutterMain.findAppBundlePath();
        flutterRunArguments.entrypoint = callbackInfo.callbackName;
        flutterRunArguments.libraryPath = callbackInfo.callbackLibraryPath;
        flutterNativeView.runFromBundle(flutterRunArguments);
    }

    static private class IncomingAction {
        public IncomingAction(String notificationActionId,
                              NotificationDetails notificationDetails,
                              BroadcastReceiver.PendingResult result) {
            this.notificationActionId = notificationActionId;
            this.notificationDetails = notificationDetails;
            this.result = result;
        }
        private final String notificationActionId;
        private final NotificationDetails notificationDetails;
        private final BroadcastReceiver.PendingResult result;
    }
}
