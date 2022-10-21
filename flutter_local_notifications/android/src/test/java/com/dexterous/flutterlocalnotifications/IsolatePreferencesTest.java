package com.dexterous.flutterlocalnotifications;

import static org.junit.Assert.assertEquals;

import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import com.dexterous.flutterlocalnotifications.isolate.IsolatePreferences;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class IsolatePreferencesTest {
  private static final Long DISPATCHER_ID = 123L;
  private static final Long HANDLE_ID = 124L;

  private Context context;

  @Before
  public void before() {
    context = ApplicationProvider.getApplicationContext();
  }

  @Test
  public void saveAndGet_ShouldReturnCorrectValues() {
    final IsolatePreferences preferences = new IsolatePreferences(context);
    preferences.saveCallbackKeys(DISPATCHER_ID, HANDLE_ID);
    assertEquals(DISPATCHER_ID, preferences.getCallbackDispatcherHandle());
    assertEquals(HANDLE_ID, preferences.getCallbackHandle());
  }
}
