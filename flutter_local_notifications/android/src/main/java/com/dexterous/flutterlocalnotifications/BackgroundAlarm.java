package com.dexterous.flutterlocalnotifications;

import static com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.retrieveSoundResourceUri;

import android.app.Notification;
import android.content.Context;
import android.media.AudioAttributes;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.VibrationAttributes;
import android.os.VibrationEffect;
import android.os.Vibrator;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;

class BackgroundAlarm {
    private static Ringtone _ringtone;
    private static Vibrator _vibrator;

    static void start(final Context context, NotificationDetails notificationDetails) {
        if (notificationDetails.playSound)
            playAlarmSound(context, notificationDetails);
        if (notificationDetails.enableVibration)
            vibrate(context, notificationDetails);
    }

    static void stop() {
        stopBackgroundSound();
        stopVibration();
    }

    private static boolean shouldLoop(NotificationDetails notificationDetails) {
        if (notificationDetails.timeoutAfter > 0) {
            for (int flag : notificationDetails.additionalFlags) {
                if (flag == Notification.FLAG_INSISTENT)
                    return true;
            }
        }
        return false;
    }

    private static void playAlarmSound(final Context context, NotificationDetails notificationDetails) {
        Ringtone r = RingtoneManager.getRingtone(
                context,
                retrieveSoundResourceUri(
                        context, notificationDetails.sound, notificationDetails.soundSource));
        if (r != null) {
            setRingtone(r);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                r.setAudioAttributes(
                        new AudioAttributes.Builder()
                                .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED)
                                .setUsage(AudioAttributes.USAGE_ALARM)
                                .build());
            }
            if (shouldLoop(notificationDetails)) {
                setRingtoneLength(r, notificationDetails);
            }
            r.play();
        }
    }

    private static void setRingtone(Ringtone ringtone) {
        stopBackgroundSound();
        _ringtone = ringtone;
    }

    private static void setRingtoneLength(Ringtone r, NotificationDetails notificationDetails) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P)
            return;
        r.setLooping(true);
        new Handler(Looper.getMainLooper())
                .postDelayed(r::stop, notificationDetails.timeoutAfter);
    }

    private static void vibrate(final Context context, NotificationDetails notificationDetails) {
        Vibrator v = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        if (v == null || !v.hasVibrator())
            return;
        setVibrator(v);
        if (!shouldLoop(notificationDetails)) {
            if (Build.VERSION.SDK_INT >= 26) {
                v.vibrate(VibrationEffect.createOneShot(1500, VibrationEffect.DEFAULT_AMPLITUDE));
            } else {
                v.vibrate(1500);
            }
            return;
        }

        long[] vibrationPattern = new long[] { 0, 500, 500 };
        if (notificationDetails.vibrationPattern != null) {
            vibrationPattern = notificationDetails.vibrationPattern;
        }

        if (Build.VERSION.SDK_INT >= 33) {
            v.vibrate(
                    VibrationEffect.createWaveform(vibrationPattern, 0),
                    VibrationAttributes.createForUsage(VibrationAttributes.USAGE_ALARM));
        } else {
            v.vibrate(vibrationPattern, 0);
        }
        new Handler(Looper.getMainLooper())
                .postDelayed(v::cancel, notificationDetails.timeoutAfter);
    }

    private static void setVibrator(Vibrator vibrator) {
        stopVibration();
        _vibrator = vibrator;
    }

    private static void stopBackgroundSound() {
        if (_ringtone != null) {
            _ringtone.stop();
        }
    }

    private static void stopVibration() {
        if (_vibrator != null) {
            _vibrator.cancel();
        }
    }
}
