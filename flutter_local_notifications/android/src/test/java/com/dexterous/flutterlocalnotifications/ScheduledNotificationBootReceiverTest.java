package com.dexterous.flutterlocalnotifications;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

import android.content.BroadcastReceiver.PendingResult;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.test.core.app.ApplicationProvider;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.shadow.api.Shadow;
import org.robolectric.shadows.ShadowBroadcastPendingResult;
import org.robolectric.shadows.ShadowBroadcastReceiver;
import org.robolectric.shadows.ShadowLooper;

@RunWith(RobolectricTestRunner.class)
public class ScheduledNotificationBootReceiverTest {
  private Context context;
  private ExecutorService executor;

  @Before
  public void before() {
    context = ApplicationProvider.getApplicationContext();
    executor = Executors.newSingleThreadExecutor();
  }

  @After
  public void after() {
    executor.shutdownNow();
  }

  @Test
  public void onReceive_ReschedulesSupportedBroadcastOffMainThreadAndFinishes() throws Exception {
    CountDownLatch rescheduleStarted = new CountDownLatch(1);
    CountDownLatch allowRescheduleToFinish = new CountDownLatch(1);
    AtomicReference<Thread> rescheduleThread = new AtomicReference<>();
    ScheduledNotificationBootReceiver receiver =
        new ScheduledNotificationBootReceiver() {
          @Override
          ExecutorService createExecutor() {
            return executor;
          }

          @Override
          void rescheduleNotifications(Context context) {
            rescheduleThread.set(Thread.currentThread());
            rescheduleStarted.countDown();
            try {
              allowRescheduleToFinish.await();
            } catch (InterruptedException exception) {
              Thread.currentThread().interrupt();
              throw new RuntimeException(exception);
            }
          }
        };
    context.registerReceiver(receiver, new IntentFilter(Intent.ACTION_MY_PACKAGE_REPLACED));

    context.sendBroadcast(new Intent(Intent.ACTION_MY_PACKAGE_REPLACED));
    ShadowLooper.idleMainLooper();

    assertTrue(rescheduleStarted.await(5, TimeUnit.SECONDS));
    ShadowBroadcastReceiver shadowReceiver = Shadow.extract(receiver);
    assertTrue(shadowReceiver.wentAsync());
    assertNotEquals(Thread.currentThread(), rescheduleThread.get());
    PendingResult pendingResult = shadowReceiver.getOriginalPendingResult();
    ShadowBroadcastPendingResult shadowPendingResult = Shadow.extract(pendingResult);
    assertFalse(shadowPendingResult.getFuture().isDone());

    allowRescheduleToFinish.countDown();

    assertSame(pendingResult, shadowPendingResult.getFuture().get(5, TimeUnit.SECONDS));
  }

  @Test
  public void onReceive_IgnoresUnsupportedBroadcast() {
    ScheduledNotificationBootReceiver receiver =
        new ScheduledNotificationBootReceiver() {
          @Override
          void rescheduleNotifications(Context context) {
            throw new AssertionError("Notifications should not be rescheduled");
          }
        };

    receiver.onReceive(context, new Intent(Intent.ACTION_AIRPLANE_MODE_CHANGED));

    assertFalse(((ShadowBroadcastReceiver) Shadow.extract(receiver)).wentAsync());
  }
}
