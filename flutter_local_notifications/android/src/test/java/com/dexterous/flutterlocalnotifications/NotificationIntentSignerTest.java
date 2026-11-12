package com.dexterous.flutterlocalnotifications;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.content.Intent;
import androidx.test.core.app.ApplicationProvider;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class NotificationIntentSignerTest {
  private Context context;

  @Before
  public void before() {
    context = ApplicationProvider.getApplicationContext();
  }

  @Test
  public void verify_signedIntent_ReturnsTrue() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    assertTrue(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithoutOptionalExtras_ReturnsTrue() {
    final Intent intent = new Intent("SELECT_NOTIFICATION");
    NotificationIntentSigner.sign(context, intent);
    assertTrue(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_unsignedIntent_ReturnsFalse() {
    assertFalse(NotificationIntentSigner.verify(context, createActionIntent()));
  }

  @Test
  public void verify_intentWithForgedSignature_ReturnsFalse() {
    final Intent intent = createActionIntent();
    intent.putExtra(NotificationIntentSigner.SIGNATURE, new byte[32]);
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedAction_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.setAction("SELECT_NOTIFICATION");
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedId_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.putExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 2);
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedTag_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.putExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_TAG, "other tag");
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedActionId_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.putExtra(FlutterLocalNotificationsPlugin.ACTION_ID, "other action");
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedCancelNotification_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.putExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, false);
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithChangedPayload_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.putExtra(FlutterLocalNotificationsPlugin.PAYLOAD, "other payload");
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  @Test
  public void verify_signedIntentWithPayloadRemoved_ReturnsFalse() {
    final Intent intent = createActionIntent();
    NotificationIntentSigner.sign(context, intent);
    intent.removeExtra(FlutterLocalNotificationsPlugin.PAYLOAD);
    assertFalse(NotificationIntentSigner.verify(context, intent));
  }

  private static Intent createActionIntent() {
    return new Intent("SELECT_FOREGROUND_NOTIFICATION")
        .putExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 1)
        .putExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_TAG, "tag")
        .putExtra(FlutterLocalNotificationsPlugin.ACTION_ID, "action")
        .putExtra(FlutterLocalNotificationsPlugin.CANCEL_NOTIFICATION, true)
        .putExtra(FlutterLocalNotificationsPlugin.PAYLOAD, "payload");
  }
}
