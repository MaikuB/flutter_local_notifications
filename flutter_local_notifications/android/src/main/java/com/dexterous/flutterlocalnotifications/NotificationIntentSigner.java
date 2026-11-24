package com.dexterous.flutterlocalnotifications;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.Nullable;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Signs the intents that notifications send to the launch activity, so that the plugin can tell
 * them apart from intents that other apps send to it.
 *
 * <p>The launch activity is exported, so any app can start it with an intent that looks like a
 * notification tap. The signature is an HMAC of the action and the extras that the plugin reads,
 * keyed with a random secret that is created once per app install. Other apps can't read the
 * contents of a {@link android.app.PendingIntent}, so they have no way to get a valid signature.
 */
final class NotificationIntentSigner {
  static final String SIGNATURE = "signature";

  private static final String TAG = "NotificationIntentSign";
  private static final String ALGORITHM = "HmacSHA256";
  private static final String KEY_FILE_NAME = "flutter_local_notifications_intent_key";
  private static final int KEY_LENGTH = 32;

  @Nullable private static byte[] key;

  private NotificationIntentSigner() {}

  static void sign(Context context, Intent intent) {
    try {
      intent.putExtra(SIGNATURE, computeSignature(context, intent));
    } catch (IOException | GeneralSecurityException e) {
      Log.e(TAG, "Failed to sign notification intent", e);
    }
  }

  static boolean verify(Context context, Intent intent) {
    byte[] signature = intent.getByteArrayExtra(SIGNATURE);
    if (signature == null) {
      return false;
    }
    try {
      return MessageDigest.isEqual(signature, computeSignature(context, intent));
    } catch (IOException | GeneralSecurityException e) {
      Log.e(TAG, "Failed to verify notification intent", e);
      return false;
    }
  }

  private static byte[] computeSignature(Context context, Intent intent)
      throws IOException, GeneralSecurityException {
    Mac mac = Mac.getInstance(ALGORITHM);
    mac.init(new SecretKeySpec(getKey(context), ALGORITHM));
    update(mac, intent.getAction());
    update(mac, intent.getIntExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 0));
    update(mac, intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_TAG));
    update(mac, intent.getStringExtra(FlutterLocalNotificationsPlugin.ACTION_ID));
    update(
        mac,
        intent.getBooleanExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, false) ? 1 : 0);
    update(mac, intent.getStringExtra(FlutterLocalNotificationsPlugin.PAYLOAD));
    return mac.doFinal();
  }

  private static void update(Mac mac, int value) {
    mac.update(ByteBuffer.allocate(Integer.BYTES).putInt(value).array());
  }

  // Strings are prefixed with their length, and null with -1, so that different sets of extras
  // can't produce the same input.
  private static void update(Mac mac, @Nullable String value) {
    if (value == null) {
      update(mac, -1);
      return;
    }
    byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
    update(mac, bytes.length);
    mac.update(bytes);
  }

  private static synchronized byte[] getKey(Context context) throws IOException {
    if (key == null) {
      // The key is kept out of backups, so it never leaves the device.
      File file = new File(context.getNoBackupFilesDir(), KEY_FILE_NAME);
      key = file.length() == KEY_LENGTH ? readKey(file) : createKey(file);
    }
    return key;
  }

  private static byte[] readKey(File file) throws IOException {
    byte[] bytes = new byte[KEY_LENGTH];
    try (DataInputStream in = new DataInputStream(new FileInputStream(file))) {
      in.readFully(bytes);
    }
    return bytes;
  }

  private static byte[] createKey(File file) throws IOException {
    byte[] bytes = new byte[KEY_LENGTH];
    new SecureRandom().nextBytes(bytes);
    // Written to a temporary file first, so that a partially written key is never read.
    File tempFile = File.createTempFile(KEY_FILE_NAME, null, file.getParentFile());
    try (FileOutputStream out = new FileOutputStream(tempFile)) {
      out.write(bytes);
    }
    if (!tempFile.renameTo(file)) {
      tempFile.delete();
      throw new IOException("Failed to save " + file);
    }
    return bytes;
  }
}
