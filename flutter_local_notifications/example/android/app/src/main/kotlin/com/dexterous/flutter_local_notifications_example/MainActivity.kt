package com.dexterous.flutter_local_notifications_example

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.ComponentName
import android.os.IBinder
import android.media.RingtoneManager
import android.util.Log
import com.dexterous.flutterlocalnotifications.ForegroundService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private var isServiceBound = false
    private val serviceStartedAction = "com.dexterous.flutterlocalnotifications.FOREGROUND_SERVICE_STARTED"
    private val serviceStoppedAction = "com.dexterous.flutterlocalnotifications.FOREGROUND_SERVICE_STOPPED"

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            isServiceBound = true
            Log.d("MainActivity", "Service bound")
        }
        override fun onServiceDisconnected(name: ComponentName?) {
            isServiceBound = false
            Log.d("MainActivity", "Service disconnected")
        }
    }

    private val serviceBroadcastReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d("MainActivity", "Received broadcast: ${intent?.action}")
            when (intent?.action) {
                serviceStartedAction -> {
                    if (!isServiceBound) {
                        val bindIntent = Intent(context, ForegroundService::class.java)
                        bindService(bindIntent, serviceConnection, Context.BIND_AUTO_CREATE)
                    }
                }
                serviceStoppedAction -> {
                    if (isServiceBound) {
                        unbindService(serviceConnection)
                        isServiceBound = false
                        Log.d("MainActivity", "Service unbound from broadcast")
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dexterx.dev/flutter_local_notifications_example").setMethodCallHandler { call, result ->
            if ("drawableToUri" == call.method) {
                val resourceId = this@MainActivity.resources.getIdentifier(call.arguments as String, "drawable", this@MainActivity.packageName)
                result.success(resourceToUriString(this@MainActivity.applicationContext, resourceId))
            }
            if ("getAlarmUri" == call.method) {
                result.success(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM).toString())
            }
        }
    }

    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = android.content.IntentFilter().apply {
            addAction(serviceStartedAction)
            addAction(serviceStoppedAction)
        }
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            registerReceiver(serviceBroadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(serviceBroadcastReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(serviceBroadcastReceiver)
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }

    private fun resourceToUriString(context: Context, resId: Int): String? {
        return (ContentResolver.SCHEME_ANDROID_RESOURCE + "://"
                + context.resources.getResourcePackageName(resId)
                + "/"
                + context.resources.getResourceTypeName(resId)
                + "/"
                + context.resources.getResourceEntryName(resId))
    }
}
