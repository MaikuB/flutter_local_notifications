package com.dexterous.flutterlocalnotifications.interfaces;

import androidx.car.app.CarAppService;

/**
 * Interface for providing CarAppService class information to the notification
 * plugin
 * for proper Android Auto support.
 * 
 * Implementing this interface allows your MainActivity to provide the
 * CarAppService
 * class that will be used to create intents for Android Auto notifications.
 * This is
 * required when using the {@code showOnAndroidAuto} notification option.
 * 
 * Example implementation:
 * 
 * public class MainActivity extends FlutterActivity implements
 * CarAppServiceClassConsumer {
 * {@literal @}Override
 * public Class{@literal <}? extends CarAppService{@literal >}
 * getCarAppServiceClass() {
 * return MyCarAppService.class;
 * }
 * }
 * 
 * 
 * Note: The CarAppService may not always be active (e.g., when connected to
 * Android Auto
 * but the app hasn't been launched yet). The plugin will work with or without a
 * CarAppService
 * being provided - this interface is only needed when {@code showOnAndroidAuto}
 * is enabled.
 * 
 * @see com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
 */
public interface CarAppServiceClassConsumer {
  /**
   * Gets the CarAppService class to be used for Android Auto notification
   * intents.
   * 
   * The returned class must extend {@code androidx.car.app.CarAppService} and
   * handle
   * notification interactions when the app is running in Android Auto mode.
   * 
   * @return The CarAppService class if Android Auto support is implemented, null
   *         otherwise
   */
  Class<? extends CarAppService> getCarAppServiceClass();
}
