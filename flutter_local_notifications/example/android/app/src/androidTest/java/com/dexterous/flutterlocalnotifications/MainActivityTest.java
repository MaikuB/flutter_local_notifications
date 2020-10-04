package com.dexterous.flutterlocalnotifications;

import androidx.test.rule.ActivityTestRule;

import com.dexterous.flutterlocalnotificationsexample.MainActivity;

import dev.flutter.plugins.e2e.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class, true, false);
}