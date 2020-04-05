# Flutter Local Notifications plugin

This repository consists hosts the following packages

- `flutter_local_notifications`: code for the cross-platform facing plugin used to display local notifications within Flutter applications
- `flutter_local_notifications_platform_interface`: the code for the common platform interface

These can be found in the corresponding directories within the same name. Most developers are likely here as they are looking to use the `flutter_local_notifications` plugin. There is a readme file within each directory with more information.

## Usage
To be able to use the plugin inside the app few preparations are required.
The plugin have to be initialized.
The initialization process is done before the app is running actually so it have to be in the `main.dart`.


### Step 1
Get instance of the plugin and add variabels

`final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();`

`NotificationAppLaunchDetails notificationAppLaunchDetails;`

### Step 2
Created streams so that app can respond to notification-related events since the plugin is initialised in the `main` function.
Those classes are coming from [rxdart](https://pub.dev/packages/rxdart)

`final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();`

`final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();`

### Step 3 
Create the class to get the notifications

    class ReceivedNotification {
      final int id;
      final String title;
      final String body;
      final String payload;
    
      ReceivedNotification({
        @required this.id,
        @required this.title,
        @required this.body,
        @required this.payload,
      });
    }


### Step 4
Make the main function to be async and to return `Future`.

	Future<void> main() async {
	  // needed if you intend to initialize in the `main` function
	  WidgetsFlutterBinding.ensureInitialized();

	  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // Note: The icon is required by Android platform and the file have to be available in the "android" resources drawabels when the application is compiled
	  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
	  // Note: permissions aren't requested here just to demonstrate 	that can be done later using the "requestPermissions()" method
	  // of the "IOSFlutterLocalNotificationsPlugin" class
	  var initializationSettingsIOS = IOSInitializationSettings(
	      requestAlertPermission: false,
	      requestBadgePermission: false,
	      requestSoundPermission: false,
	      onDidReceiveLocalNotification:
	          (int id, String title, String body, String payload) async {
	        didReceiveLocalNotificationSubject.add(ReceivedNotification(
	            id: id, title: title, body: body, payload: payload));
	      });
	  var initializationSettings = InitializationSettings(
	      initializationSettingsAndroid, initializationSettingsIOS);
	  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
	      onSelectNotification: (String payload) async {
	    if (payload != null) {
	      debugPrint('notification payload: ' + payload);
	    }
	    selectNotificationSubject.add(payload);
	  });
	  
	  //Here you should add the "runApp" code
	}`

## Issues

If you run into bugs, please raise them on the GitHub repository. Please do not email them to me as GitHub is the appropriate place for them and allows for members of the community to answer questions, particularly if I miss the email. It would also be much appreciated if they could be limited to actual bugs or feature requests. If you're looking at how you could use the plugin to do a particular kind of notification, check the example app provides detailed code samples for each supported feature. Also try to check the README first in case you have missed something e.g. platform-specific setup.

## Contributions

Contributions are welcome by submitting a PR for to be reviewed. If it's to add new features, appreciate it if you could try to maintain the architecture or try to improve on it. If you are looking to add platform-specific functionality do not add this to the cross-platform facing API (i.e. the [`FlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/FlutterLocalNotificationsPlugin-class.html) class. The recommended approaches in this scenario are:

1. see if it can be passed as platform-specific configuration or
2. add methods to the platform-specific implementations. For example, on iOS there is an [`IOSFlutterLocalNotificationsPlugin`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin-class.html) class. You may notice there's a [`requestPermissions()`](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/IOSFlutterLocalNotificationsPlugin/requestPermissions.html) method that only exists there

