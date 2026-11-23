package com.dexterous.flutterlocalnotifications;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class NotificationAppLaunchDetailsTest {
  private FlutterLocalNotificationsPlugin plugin;

  @Before
  public void before() {
    final Intent intent = new Intent("SELECT_NOTIFICATION");
    intent.putExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 1);
    intent.putExtra(FlutterLocalNotificationsPlugin.PAYLOAD, "payload");
    final Activity activity = Robolectric.buildActivity(Activity.class, intent).get();
    final ActivityPluginBinding binding = mock(ActivityPluginBinding.class);
    when(binding.getActivity()).thenReturn(activity);
    plugin = new FlutterLocalNotificationsPlugin();
    plugin.onAttachedToActivity(binding);
  }

  @Test
  public void getNotificationAppLaunchDetails_returnsDetailsOfLaunchingNotification() {
    final Map<String, Object> details = getNotificationAppLaunchDetails();
    assertEquals(true, details.get("notificationLaunchedApp"));
    final Map<?, ?> notificationResponse = (Map<?, ?>) details.get("notificationResponse");
    assertEquals(1, notificationResponse.get(FlutterLocalNotificationsPlugin.NOTIFICATION_ID));
    assertEquals("payload", notificationResponse.get(FlutterLocalNotificationsPlugin.PAYLOAD));
  }

  @Test
  public void clearNotificationAppLaunchDetails_clearsDetailsOfLaunchingNotification() {
    final Result result = mock(Result.class);
    plugin.onMethodCall(new MethodCall("clearNotificationAppLaunchDetails", null), result);
    verify(result).success(null);

    final Map<String, Object> details = getNotificationAppLaunchDetails();
    assertEquals(false, details.get("notificationLaunchedApp"));
    assertFalse(details.containsKey("notificationResponse"));
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> getNotificationAppLaunchDetails() {
    final Result result = mock(Result.class);
    plugin.onMethodCall(new MethodCall("getNotificationAppLaunchDetails", null), result);
    final ArgumentCaptor<Object> captor = ArgumentCaptor.forClass(Object.class);
    verify(result).success(captor.capture());
    return (Map<String, Object>) captor.getValue();
  }
}
