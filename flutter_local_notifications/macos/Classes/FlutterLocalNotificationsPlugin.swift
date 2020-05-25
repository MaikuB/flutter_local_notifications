import Cocoa
import FlutterMacOS
import UserNotifications

public class FlutterLocalNotificationsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    enum ScheduledNotificationRepeatFrequency : Int {
        case daily
        case weekly
    }
    
    enum RepeatInterval: Int {
        case everyMinute
        case hourly
        case daily
        case weekly
    }
    
    var channel: FlutterMethodChannel
    var initialized = false
    var defaultPresentAlert = false
    var defaultPresentSound = false
    var defaultPresentBadge = false
    var launchPayload: String?
    var launchingAppFromNotification = false
    
    init(fromChannel channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dexterous.com/flutter/local_notifications", binaryMessenger: registrar.messenger)
        let instance = FlutterLocalNotificationsPlugin.init(fromChannel: channel)
        if #available(OSX 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = instance
        } else {
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @available(OSX 10.14, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var options:UNNotificationPresentationOptions = [];
        let presentAlert = notification.request.content.userInfo["presentAlert"] as! Bool
        let presentSound = notification.request.content.userInfo["presentSound"] as! Bool
        let presentBadge = notification.request.content.userInfo["presentBadge"] as! Bool
        if presentAlert {
            options.insert(.alert)
        }
        if presentSound {
            options.insert(.sound)
        }
        if presentBadge {
            options.insert(.badge)
        }
        completionHandler(options)
    }
    
    @available(OSX 10.14, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let payload = response.notification.request.content.userInfo["payload"] as? String
        if(initialized) {
            handleSelectNotification(payload: payload)
        } else {
            launchPayload = payload
            launchingAppFromNotification = true
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            defaultPresentAlert = arguments["defaultPresentAlert"] as! Bool
            defaultPresentSound = arguments["defaultPresentSound"] as! Bool
            defaultPresentBadge = arguments["defaultPresentBadge"] as! Bool
            let requestedSoundPermission = arguments["requestSoundPermission"] as! Bool
            let requestedAlertPermission = arguments["requestAlertPermission"] as! Bool
            let requestedBadgePermission = arguments["requestBadgePermission"] as! Bool
            requestPermissionsImpl(soundPermission: requestedSoundPermission, alertPermission: requestedAlertPermission, badgePermission: requestedBadgePermission, result: result)
            if(launchingAppFromNotification) {
                handleSelectNotification(payload: launchPayload)
            }
        case "requestPermissions":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let requestedSoundPermission = arguments["sound"] as! Bool
            let requestedAlertPermission = arguments["alert"] as! Bool
            let requestedBadgePermission = arguments["badge"] as! Bool
            requestPermissionsImpl(soundPermission: requestedSoundPermission, alertPermission: requestedAlertPermission, badgePermission: requestedBadgePermission, result: result)
        case "getNotificationAppLaunchDetails":
            let appLaunchDetails : [String: Any?] = ["notificationLaunchedApp" : launchingAppFromNotification, "payload": launchPayload]
            result(appLaunchDetails)
        case "cancel":
            if #available(OSX 10.14, *) {
                let center = UNUserNotificationCenter.current()
                let idsToRemove = [String(call.arguments as! Int)]
                center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
                center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
            }
            else {
                
            }
        case "cancelAll":
            if #available(OSX 10.14, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                center.removeAllDeliveredNotifications()
            }
        case "pendingNotificationRequests":
            if #available(OSX 10.14, *) {
                 UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                    var requestDictionaries:[Dictionary<String, Any?>] = []
                    for request in requests {
                        requestDictionaries.append(["id":Int(request.identifier) as Any, "title": request.content.title, "body": request.content.body, "payload": request.content.userInfo["payload"]])
                    }
                    result(requestDictionaries)
                }
            } else {
                // Fallback on earlier versions
            }
        case "show":
            if #available(OSX 10.14, *) {
                do {
                    let arguments = call.arguments as! Dictionary<String, AnyObject>
                    let content = try buildUserNotificationContent(arguments: arguments)
                    let center = UNUserNotificationCenter.current()
                    let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: nil)
                    center.add(request)
                    result(nil)
                } catch {
                    result(FlutterError.init(code: "show_error", message: error.localizedDescription, details: "\(error)"))
                }
            } else {
                // Fallback on earlier versions
            }
        case "zonedSchedule":
            if #available(OSX 10.14, *) {
                do {
                    let arguments = call.arguments as! Dictionary<String, AnyObject>
                    let content = try buildUserNotificationContent(arguments: arguments)
                    let trigger = buildUserNotificationCalendarTrigger(fromArguments: arguments)
                    let center = UNUserNotificationCenter.current()
                    let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: trigger)
                    center.add(request)
                    result(nil)
                } catch {
                    result(FlutterError.init(code: "\(call.method)_error", message: error.localizedDescription, details: "\(error)"))
                }
            } else {
                // Fallback on earlier versions
            }
        case "periodicallyShow":
            if #available(OSX 10.14, *) {
                do {
                    let arguments = call.arguments as! Dictionary<String, AnyObject>
                    let content = try buildUserNotificationContent(arguments: arguments)
                    let trigger = buildUserNotificationTimeIntervalTrigger(fromArguments: arguments)
                    let center = UNUserNotificationCenter.current()
                    let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: trigger)
                    center.add(request)
                    result(nil)
                } catch {
                    result(FlutterError.init(code: "\(call.method)_error", message: error.localizedDescription, details: "\(error)"))
                }
            } else {
                // Fallback on earlier versions
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @available(OSX 10.14, *)
    func buildUserNotificationContent(arguments: Dictionary<String, AnyObject>) throws -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        if let title = arguments["title"] as? String {
            content.title = title
        }
        if let subtitle = arguments["subtitle"] as? String {
            content.subtitle = subtitle
        }
        if let body = arguments["body"] as? String {
            content.body = body
        }
        var presentSound = defaultPresentSound
        var presentBadge = defaultPresentBadge
        var presentAlert = defaultPresentAlert
        if let platformSpecifics = arguments["platformSpecifics"] as? Dictionary<String, AnyObject> {
            if let sound = platformSpecifics["sound"] as? String {
                content.sound = UNNotificationSound.init(named: UNNotificationSoundName.init(sound))
            }
            if let badgeNumber = platformSpecifics["badgeNumber"] as? NSNumber {
                content.badge = badgeNumber
            }
            if !(platformSpecifics["presentSound"] is NSNull) && platformSpecifics["presentSound"] != nil {
                presentSound = platformSpecifics["presentSound"] as! Bool
            }
            if !(platformSpecifics["presentAlert"] is NSNull) && platformSpecifics["presentAlert"] != nil {
                presentAlert = platformSpecifics["presentAlert"] as! Bool
            }
            if !(platformSpecifics["presentBadge"] is NSNull) && platformSpecifics["presentBadge"] != nil {
                presentBadge = platformSpecifics["presentBadge"] as! Bool
            }
            if let attachments = platformSpecifics["attachments"] as? [Dictionary<String, AnyObject>] {
                content.attachments = []
                for attachment in attachments {
                    let identifier = attachment["identifier"] as! String
                    let filePath = attachment["filePath"] as! String
                    let notificationAttachment = try UNNotificationAttachment.init(identifier: identifier, url: URL.init(fileURLWithPath: filePath))
                    content.attachments.append(notificationAttachment)
                }
            }
        }
        content.userInfo = ["payload": arguments["payload"] as Any, "presentSound": presentSound, "presentBadge": presentBadge, "presentAlert": presentAlert]
        if presentSound && content.sound == nil {
            content.sound = UNNotificationSound.default
        }
        return content
    }
    
    @available(OSX 10.14, *)
    func buildUserNotificationCalendarTrigger(fromArguments arguments:Dictionary<String, AnyObject>) -> UNCalendarNotificationTrigger {
        let scheduledDateTime = arguments["scheduledDateTime"] as! String;
        let timezoneName = arguments["timezoneName"] as! String;
        let timezone = TimeZone.init(identifier: timezoneName)
        let dateFormatter = DateFormatter.init();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = timezone
        let date = dateFormatter.date(from: scheduledDateTime)!
        var calendar = Calendar.current
        calendar.timeZone = timezone!
        if let rawRepeatFrequency = arguments["scheduledNotificationRepeatFrequency"] as? Int {
            let repeatFrequency = ScheduledNotificationRepeatFrequency.init(rawValue: rawRepeatFrequency)!
            switch repeatFrequency {
            case .daily:
                let dateComponents = calendar.dateComponents([.day, .hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            case .weekly:
                let dateComponents = calendar.dateComponents([ .weekday,.hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            }
        }
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date)
        return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
    }
    
    @available(OSX 10.14, *)
    func buildUserNotificationTimeIntervalTrigger(fromArguments arguments:Dictionary<String, AnyObject>) -> UNTimeIntervalNotificationTrigger {
        let rawRepeatInterval = arguments["repeatInterval"] as! Int
        let repeatInterval = RepeatInterval.init(rawValue: rawRepeatInterval)!
        switch repeatInterval {
        case .everyMinute:
            return UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: true)
        case .hourly:
            return UNTimeIntervalNotificationTrigger.init(timeInterval: 60 * 60, repeats: true)
        case .daily:
            return UNTimeIntervalNotificationTrigger.init(timeInterval: 60 * 60 * 24, repeats: true)
        case .weekly:
            return UNTimeIntervalNotificationTrigger.init(timeInterval: 60 * 60 * 24 * 7, repeats: true)
        }

    }
    
    func getIdentifier(fromArguments arguments: Dictionary<String, AnyObject>) -> String {
        return String(arguments["id"] as! Int)
    }
    
    func requestPermissionsImpl(soundPermission: Bool, alertPermission: Bool, badgePermission: Bool, result: @escaping FlutterResult) {
        if #available(OSX 10.14, *) {
            let center = UNUserNotificationCenter.current()
            var options: UNAuthorizationOptions = []
            if(soundPermission) {
                options.insert(.sound)
            }
            if(alertPermission) {
                options.insert(.alert)
            }
            if(badgePermission) {
                options.insert(.badge)
            }
            center.requestAuthorization(options: options) { (granted, error) in
                result(granted)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func handleSelectNotification(payload: String?) {
        channel.invokeMethod("selectNotification", arguments: payload)
    }
}
