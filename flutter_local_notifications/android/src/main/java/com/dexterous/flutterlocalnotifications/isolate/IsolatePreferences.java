package com.dexterous.flutterlocalnotifications.isolate;

import android.content.Context;
import android.content.SharedPreferences;

public class IsolatePreferences {

	private static final String SHARED_PREFS_FILE_NAME = "flutter_local_notifications_plugin";
	private static final String CALLBACK_DISPATCHER_HANDLE_KEY =
			"com.dexterous.flutterlocalnotifications.CALLBACK_DISPATCHER_HANDLE_KEY";
	private static final String CALLBACK_HANDLE_KEY =
			"com.dexterous.flutterlocalnotifications.CALLBACK_HANDLE_KEY";

	public static SharedPreferences get(Context context) {
		return context.getSharedPreferences(SHARED_PREFS_FILE_NAME, Context.MODE_PRIVATE);
	}

	public static void saveCallbackKeys(Context context, Long dispatcherCallbackHandle,
			Long callbackHandle) {
		get(context).edit().putLong(CALLBACK_DISPATCHER_HANDLE_KEY, dispatcherCallbackHandle).apply();
		get(context).edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
	}

	public static Long getCallbackDispatcherHandle(Context context) {
		return get(context).getLong(CALLBACK_DISPATCHER_HANDLE_KEY, -1L);
	}

	public static Long getCallbackHandle(Context context) {
		return get(context).getLong(CALLBACK_HANDLE_KEY, -1L);
	}

	public static boolean hasCallbackHandle(Context context) {
		return get(context).contains(CALLBACK_DISPATCHER_HANDLE_KEY);
	}
}
