package com.dexterous.flutterlocalnotifications;

import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import android.content.Context;
import android.content.Intent;
import androidx.test.core.app.ApplicationProvider;
import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ActionBroadcastReceiverTest {
  private Context context;

  @Mock IsolatePreferences isolatePreferences;

  @Before
  public void before() {
    MockitoAnnotations.openMocks(this);

    context = ApplicationProvider.getApplicationContext();
  }

  @Test
  public void incorrectIntent_shouldNotPerformAction() {
    final ActionBroadcastReceiver receiver = new ActionBroadcastReceiver(isolatePreferences);
    receiver.onReceive(context, new Intent("INVALID_ACTION"));

    verify(isolatePreferences, never()).lookupDispatcherHandle();
  }

  @Test
  public void correctIntent_triggersLookup() {
    final ActionBroadcastReceiver receiver = new ActionBroadcastReceiver(isolatePreferences);
    receiver.onReceive(context, new Intent(ActionBroadcastReceiver.ACTION_TAPPED));

    verify(isolatePreferences).lookupDispatcherHandle();
  }
}
