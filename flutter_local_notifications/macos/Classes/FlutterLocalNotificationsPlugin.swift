import Cocoa
import FlutterMacOS
import UserNotifications

public class FlutterLocalNotificationsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {

    struct MethodCallArguments {
        static let presentAlert = "presentAlert"
        static let presentSound = "presentSound"
        static let presentBadge = "presentBadge"
        static let presentBanner = "presentBanner"
        static let presentList = "presentList"
        static let payload = "payload"
        static let requestAlertPermission = "requestAlertPermission"
        static let requestSoundPermission = "requestSoundPermission"
        static let requestBadgePermission = "requestBadgePermission"
        static let requestProvisionalPermission = "requestProvisionalPermission"
        static let requestCriticalPermission = "requestCriticalPermission"
        static let defaultPresentAlert = "defaultPresentAlert"
        static let defaultPresentSound = "defaultPresentSound"
        static let defaultPresentBadge = "defaultPresentBadge"
        static let defaultPresentBanner = "defaultPresentBanner"
        static let defaultPresentList = "defaultPresentList"
        static let alert = "alert"
        static let sound = "sound"
        static let badge = "badge"
        static let provisional = "provisional"
        static let critical = "critical"
        static let notificationLaunchedApp = "notificationLaunchedApp"
        static let id = "id"
        static let title = "title"
        static let subtitle = "subtitle"
        static let categoryIdentifier = "categoryIdentifier"
        static let body = "body"
        static let scheduledDateTime = "scheduledDateTimeISO8601"
        static let timeZoneName = "timeZoneName"
        static let matchDateTimeComponents = "matchDateTimeComponents"
        static let platformSpecifics = "platformSpecifics"
        static let badgeNumber = "badgeNumber"
        static let repeatInterval = "repeatInterval"
        static let repeatIntervalMilliseconds = "repeatIntervalMilliseconds"
        static let attachments = "attachments"
        static let identifier = "identifier"
        static let filePath = "filePath"
        static let hideThumbnail = "hideThumbnail"
        static let attachmentThumbnailClippingRect = "thumbnailClippingRect"
        static let threadIdentifier = "threadIdentifier"
        static let interruptionLevel = "interruptionLevel"
        static let actionId = "actionId"
        static let notificationResponseType = "notificationResponseType"
        static let isNotificationsEnabled = "isEnabled"
        static let isSoundEnabled = "isSoundEnabled"
        static let isAlertEnabled = "isAlertEnabled"
        static let isBadgeEnabled = "isBadgeEnabled"
        static let isProvisionalEnabled = "isProvisionalEnabled"
        static let isCriticalEnabled = "isCriticalEnabled"
    }

    struct ErrorMessages {
        static let getActiveNotificationsErrorMessage = "macOS version must be 10.14 or newer to use getActiveNotifications"
    }

    struct ErrorCodes {
        static let unsupportedOSVersion = "unsupported_os_version"
    }

    struct DateFormatStrings {
        static let isoFormat = "yyyy-MM-dd'T'HH:mm:ss"
    }

    enum ScheduledNotificationRepeatFrequency: Int {
        case daily
        case weekly
    }

    enum DateTimeComponents: Int {
        case time
        case dayOfWeekAndTime
        case dayOfMonthAndTime
        case dateAndTime
    }

    enum RepeatInterval: Int {
        case everyMinute
        case hourly
        case daily
        case weekly
    }

    var channel: FlutterMethodChannel
    var initialized = false
    var launchNotificationResponseDict: [String: Any?]?
    var launchingAppFromNotification = false
    let presentationOptionsUserDefaults = "flutter_local_notifications_presentation_options"

    // MARK: - FlutterPlugin initialization and registration

    init(fromChannel channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dexterous.com/flutter/local_notifications", binaryMessenger: registrar.messenger)
        let instance = FlutterLocalNotificationsPlugin.init(fromChannel: channel)
        if #available(macOS 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = instance
        } else {
            let center = NSUserNotificationCenter.default
            center.delegate = instance
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - UNUserNotificationCenterDelegate

    @available(macOS 10.14, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if !isAFlutterLocalNotification(userInfo: notification.request.content.userInfo) {
            return
        }
        var options: UNNotificationPresentationOptions = []
        let presentAlert = notification.request.content.userInfo[MethodCallArguments.presentAlert] as! Bool
        let presentSound = notification.request.content.userInfo[MethodCallArguments.presentSound] as! Bool
        let presentBadge = notification.request.content.userInfo[MethodCallArguments.presentBadge] as! Bool
        if #available(macOS 11.0, *) {
            let presentBanner = notification.request.content.userInfo[MethodCallArguments.presentBanner] as! Bool
            let presentList = notification.request.content.userInfo[MethodCallArguments.presentList] as! Bool
            if presentBanner {
                options.insert(.banner)
            }
            if presentList {
                options.insert(.list)
            }
        } else {
            if presentAlert {
                options.insert(.alert)
            }
        }
        if presentSound {
            options.insert(.sound)
        }
        if presentBadge {
            options.insert(.badge)
        }
        completionHandler(options)
    }

    @available(macOS 10.14, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if !isAFlutterLocalNotification(userInfo: response.notification.request.content.userInfo) {
            return
        }
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let payload = response.notification.request.content.userInfo[MethodCallArguments.payload] as? String
            if initialized {
                handleSelectNotification(notificationId: Int(response.notification.request.identifier)!, payload: payload)
            } else {
                launchNotificationResponseDict = extractNotificationResponseDict(response: response)
                launchingAppFromNotification = true
            }

            completionHandler()
        } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            completionHandler()
        } else {
            if initialized {
                // No isolate can be used for macOS until https://github.com/flutter/flutter/issues/65222 is resolved.
                //
                // Therefore, we call the regular method channel and let the macos plugin handle it appropriately.
                handleSelectNotificationAction(arguments: extractNotificationResponseDict(response: response))
            } else {
                launchNotificationResponseDict = extractNotificationResponseDict(response: response)
                launchingAppFromNotification = true
            }

            completionHandler()
        }
    }

    // MARK: - NSUserNotificationCenterDelegate

    @available(macOS, introduced: 10.8, deprecated: 11.0)
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if notification.activationType == .contentsClicked && notification.userInfo != nil && isAFlutterLocalNotification(userInfo: notification.userInfo!) {
            handleSelectNotification(notificationId: Int(notification.identifier!)!, payload: notification.userInfo![MethodCallArguments.payload] as? String)
        }
    }

    @available(macOS, introduced: 10.8, deprecated: 11.0)
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    // MARK: - FlutterPlugin implementation

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call, result)
        case "requestPermissions":
            requestPermissions(call, result)
        case "checkPermissions":
            checkPermissions(call, result)
        case "getNotificationAppLaunchDetails":
            getNotificationAppLaunchDetails(result)
        case "cancel":
            cancel(call, result)
        case "cancelAll":
            cancelAll(result)
        case "pendingNotificationRequests":
            pendingNotificationRequests(result)
        case "getActiveNotifications":
            getActiveNotifications(result)
        case "show":
            show(call, result)
        case "zonedSchedule":
            zonedSchedule(call, result)
        case "periodicallyShow":
            periodicallyShow(call, result)
        case "periodicallyShowWithDuration":
            periodicallyShow(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func initialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: AnyObject]
        let defaultPresentAlert = arguments[MethodCallArguments.defaultPresentAlert] as! Bool
        let defaultPresentSound = arguments[MethodCallArguments.defaultPresentSound] as! Bool
        let defaultPresentBadge = arguments[MethodCallArguments.defaultPresentBadge] as! Bool
        let defaultPresentBanner = arguments[MethodCallArguments.defaultPresentBanner] as! Bool
        let defaultPresentList = arguments[MethodCallArguments.defaultPresentList] as! Bool
        UserDefaults.standard.set([MethodCallArguments.presentAlert: defaultPresentAlert, MethodCallArguments.presentBadge: defaultPresentBadge, MethodCallArguments.presentSound: defaultPresentSound, MethodCallArguments.presentBanner: defaultPresentBanner, MethodCallArguments.presentList: defaultPresentList], forKey: presentationOptionsUserDefaults)
        if #available(macOS 10.14, *) {
            let requestedAlertPermission = arguments[MethodCallArguments.requestAlertPermission] as! Bool
            let requestedSoundPermission = arguments[MethodCallArguments.requestSoundPermission] as! Bool
            let requestedBadgePermission = arguments[MethodCallArguments.requestBadgePermission] as! Bool
            let requestProvisionalPermission = arguments[MethodCallArguments.requestProvisionalPermission] as! Bool
            let requestedCriticalPermission = arguments[MethodCallArguments.requestCriticalPermission] as! Bool

            configureNotificationCategories(arguments) {
                self.requestPermissionsImpl(
                    soundPermission: requestedSoundPermission,
                    alertPermission: requestedAlertPermission,
                    badgePermission: requestedBadgePermission,
                    provisionalPermission: requestProvisionalPermission,
                    criticalPermission: requestedCriticalPermission,
                    result: result
                )
            }

            initialized = true
        } else {
            result(true)
            initialized = true
        }
    }

    func configureNotificationCategories(_ arguments: [String: AnyObject],
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        if #available(macOS 10.14, *) {
            if let categories = arguments["notificationCategories"] as? [[String: AnyObject]] {
                var notificationCategories = Set<UNNotificationCategory>()

                for category in categories {
                    var newActions = [UNNotificationAction]()

                    if let actions = category["actions"] as? [[String: AnyObject]] {
                        for action in actions {
                            let type = action["type"] as! String
                            let identifier = action["identifier"] as! String
                            let title = action["title"] as! String
                            let options = action["options"] as! [Any]
                            if type == "plain" {
                                newActions.append(UNNotificationAction(
                                    identifier: identifier,
                                    title: title,
                                    options: Converters.parseNotificationActionOptions(options)
                                ))
                            } else if type == "text" {
                                let buttonTitle = action["buttonTitle"] as! String
                                let placeholder = action["placeholder"] as! String
                                newActions.append(UNTextInputNotificationAction(
                                    identifier: identifier,
                                    title: title,
                                    options: Converters.parseNotificationActionOptions(options),
                                    textInputButtonTitle: buttonTitle,
                                    textInputPlaceholder: placeholder
                                ))
                            }
                        }
                    }

                    let notificationCategory = UNNotificationCategory(
                        identifier: category["identifier"] as! String,
                        actions: newActions,
                        intentIdentifiers: [],
                        hiddenPreviewsBodyPlaceholder: nil,
                        categorySummaryFormat: nil,
                        options: Converters.parseNotificationCategoryOptions(category["options"] as! [NSNumber])
                    )

                    notificationCategories.insert(notificationCategory)
                }

                if !notificationCategories.isEmpty {
                    let center = UNUserNotificationCenter.current()
                    center.setNotificationCategories(notificationCategories)
                }

                completionHandler()

            } else {
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    func requestPermissions(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            let arguments = call.arguments as! [String: AnyObject]
            let requestedAlertPermission = arguments[MethodCallArguments.alert] as! Bool
            let requestedSoundPermission = arguments[MethodCallArguments.sound] as! Bool
            let requestedBadgePermission = arguments[MethodCallArguments.badge] as! Bool
            let requestedProvisionalPermission = arguments[MethodCallArguments.provisional] as! Bool
            let requestedCriticalPermission = arguments[MethodCallArguments.critical] as! Bool

            requestPermissionsImpl(soundPermission: requestedSoundPermission, alertPermission: requestedAlertPermission, badgePermission: requestedBadgePermission, provisionalPermission: requestedProvisionalPermission, criticalPermission: requestedCriticalPermission, result: result)
        } else {
            result(nil)
        }
    }

    func getNotificationAppLaunchDetails(_ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            let appLaunchDetails: [String: Any?] = [MethodCallArguments.notificationLaunchedApp: launchingAppFromNotification, "notificationResponse": launchNotificationResponseDict]
            result(appLaunchDetails)
        } else {
            result(nil)
        }
    }

    func cancel(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            let center = UNUserNotificationCenter.current()
            let idsToRemove = [String(call.arguments as! Int)]
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
            center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
            result(nil)
        } else {
            let id = String(call.arguments as! Int)
            let center = NSUserNotificationCenter.default
            for scheduledNotification in center.scheduledNotifications {
                if scheduledNotification.identifier == id {
                    center.removeScheduledNotification(scheduledNotification)
                    break
                }
            }
            let notification = NSUserNotification.init()
            notification.identifier = id
            center.removeDeliveredNotification(notification)
            result(nil)
        }
    }

    func cancelAll(_ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
            result(nil)
        } else {
            let center = NSUserNotificationCenter.default
            for scheduledNotification in center.scheduledNotifications {
                center.removeScheduledNotification(scheduledNotification)
            }
            center.removeAllDeliveredNotifications()
            result(nil)
        }
    }

    func pendingNotificationRequests(_ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                var requestDictionaries: [[String: Any?]] = []
                for request in requests {
                    requestDictionaries.append([MethodCallArguments.id: Int(request.identifier) as Any, MethodCallArguments.title: request.content.title, MethodCallArguments.body: request.content.body, MethodCallArguments.payload: request.content.userInfo[MethodCallArguments.payload]])
                }
                result(requestDictionaries)
            }
        } else {
            var requestDictionaries: [[String: Any?]] = []
            let center = NSUserNotificationCenter.default
            for scheduledNotification in center.scheduledNotifications {
                requestDictionaries.append([MethodCallArguments.id: Int(scheduledNotification.identifier!) as Any, MethodCallArguments.title: scheduledNotification.title, MethodCallArguments.body: scheduledNotification.informativeText, MethodCallArguments.payload: scheduledNotification.userInfo![MethodCallArguments.payload]])
            }
            result(requestDictionaries)
        }
    }

    func getActiveNotifications(_ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications { (requests) in
                var requestDictionaries: [[String: Any?]] = []
                for request in requests {
                    requestDictionaries.append([MethodCallArguments.id: Int(request.request.identifier) as Any, MethodCallArguments.title: request.request.content.title, MethodCallArguments.body: request.request.content.body, MethodCallArguments.payload: request.request.content.userInfo[MethodCallArguments.payload]])
                }
                result(requestDictionaries)
            }
        } else {
            result(FlutterError.init(code: ErrorCodes.unsupportedOSVersion, message: ErrorMessages.getActiveNotificationsErrorMessage, details: nil))
        }
    }

    func show(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            do {
                let arguments = call.arguments as! [String: AnyObject]
                let content = try buildUserNotificationContent(fromArguments: arguments)
                let center = UNUserNotificationCenter.current()
                let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: nil)
                center.add(request)
                result(nil)
            } catch {
                result(buildFlutterError(forMethodCallName: call.method, withError: error))
            }
        } else {
            let arguments = call.arguments as! [String: AnyObject]
            let notification = buildNSUserNotification(fromArguments: arguments)
            NSUserNotificationCenter.default.deliver(notification)
            result(nil)
        }
    }

    func zonedSchedule(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            do {
                let arguments = call.arguments as! [String: AnyObject]
                let content = try buildUserNotificationContent(fromArguments: arguments)
                let trigger = buildUserNotificationCalendarTrigger(fromArguments: arguments)
                let center = UNUserNotificationCenter.current()
                let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: trigger)
                center.add(request)
                result(nil)
            } catch {
                result(buildFlutterError(forMethodCallName: call.method, withError: error))
            }
        } else {
            let arguments = call.arguments as! [String: AnyObject]
            let notification = buildNSUserNotification(fromArguments: arguments)
            let scheduledDateTime = arguments[MethodCallArguments.scheduledDateTime] as! String
            let timeZoneName = arguments[MethodCallArguments.timeZoneName] as! String
            let timeZone = TimeZone.init(identifier: timeZoneName)
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
            let date = dateFormatter.date(from: scheduledDateTime)!
            notification.deliveryDate = date
            notification.deliveryTimeZone = timeZone
            if let rawDateTimeComponents = arguments[MethodCallArguments.matchDateTimeComponents] as? Int {
                let dateTimeComponents = DateTimeComponents.init(rawValue: rawDateTimeComponents)!
                switch dateTimeComponents {
                case .time:
                    notification.deliveryRepeatInterval = DateComponents.init(day: 1)
                case .dayOfWeekAndTime:
                    notification.deliveryRepeatInterval = DateComponents.init(weekOfYear: 1)
                case .dayOfMonthAndTime:
                    notification.deliveryRepeatInterval = DateComponents.init(month: 1)
                case .dateAndTime:
                    notification.deliveryRepeatInterval = DateComponents.init(year: 1)
                }
            }
            NSUserNotificationCenter.default.scheduleNotification(notification)
            result(nil)
        }
    }

    func periodicallyShow(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            do {
                let arguments = call.arguments as! [String: AnyObject]
                let content = try buildUserNotificationContent(fromArguments: arguments)
                let trigger = buildUserNotificationTimeIntervalTrigger(fromArguments: arguments)
                let center = UNUserNotificationCenter.current()
                let request = UNNotificationRequest(identifier: getIdentifier(fromArguments: arguments), content: content, trigger: trigger)
                center.add(request)
                result(nil)
            } catch {
                result(buildFlutterError(forMethodCallName: call.method, withError: error))
            }
        } else {
            let arguments = call.arguments as! [String: AnyObject]
            let notification = buildNSUserNotification(fromArguments: arguments)
            let rawRepeatInterval = arguments[MethodCallArguments.repeatInterval] as? Int
            let repeatIntervalMilliseconds = arguments[MethodCallArguments.repeatIntervalMilliseconds] as? Int

            if rawRepeatInterval != nil {
                let repeatInterval = RepeatInterval.init(rawValue: rawRepeatInterval!)!
                switch repeatInterval {
                case .everyMinute:
                    notification.deliveryDate = Date.init(timeIntervalSinceNow: 60)
                    notification.deliveryRepeatInterval = DateComponents.init(minute: 1)
                case .hourly:
                    notification.deliveryDate = Date.init(timeIntervalSinceNow: 60 * 60)
                    notification.deliveryRepeatInterval = DateComponents.init(hour: 1)
                case .daily:
                    notification.deliveryDate = Date.init(timeIntervalSinceNow: 60 * 60 * 24)
                    notification.deliveryRepeatInterval = DateComponents.init(day: 1)
                case .weekly:
                    notification.deliveryDate = Date.init(timeIntervalSinceNow: 60 * 60 * 24 * 7)
                    notification.deliveryRepeatInterval = DateComponents.init(weekOfYear: 1)
                }
            } else if repeatIntervalMilliseconds != nil {
                let repeatIntervalSeconds = repeatIntervalMilliseconds! / 1000
                notification.deliveryDate = Date.init(timeIntervalSinceNow: TimeInterval(repeatIntervalSeconds))
                notification.deliveryRepeatInterval = DateComponents.init(second: repeatIntervalSeconds)
            }
            NSUserNotificationCenter.default.scheduleNotification(notification)
            result(nil)
        }
    }

    @available(macOS 10.14, *)
    func buildUserNotificationContent(fromArguments arguments: [String: AnyObject]) throws -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        if let title = arguments[MethodCallArguments.title] as? String {
            content.title = title
        }
        if let subtitle = arguments[MethodCallArguments.subtitle] as? String {
            content.subtitle = subtitle
        }
        if let body = arguments[MethodCallArguments.body] as? String {
            content.body = body
        }
        let persistedPresentationOptions = UserDefaults.standard.dictionary(forKey: presentationOptionsUserDefaults)!
        var presentSound = persistedPresentationOptions[MethodCallArguments.presentSound] as! Bool
        var presentBadge = persistedPresentationOptions[MethodCallArguments.presentBadge] as! Bool
        var presentAlert = persistedPresentationOptions[MethodCallArguments.presentAlert] as! Bool
        var presentBanner = persistedPresentationOptions[MethodCallArguments.presentBanner] as! Bool
        var presentList = persistedPresentationOptions[MethodCallArguments.presentList] as! Bool
        if let platformSpecifics = arguments[MethodCallArguments.platformSpecifics] as? [String: AnyObject] {
            if let sound = platformSpecifics[MethodCallArguments.sound] as? String {
                content.sound = UNNotificationSound.init(named: UNNotificationSoundName.init(sound))
            }
            if let badgeNumber = platformSpecifics[MethodCallArguments.badgeNumber] as? NSNumber {
                content.badge = badgeNumber
            }
            if !(platformSpecifics[MethodCallArguments.presentSound] is NSNull) && platformSpecifics[MethodCallArguments.presentSound] != nil {
                presentSound = platformSpecifics[MethodCallArguments.presentSound] as! Bool
            }
            if !(platformSpecifics[MethodCallArguments.presentAlert] is NSNull) && platformSpecifics[MethodCallArguments.presentAlert] != nil {
                presentAlert = platformSpecifics[MethodCallArguments.presentAlert] as! Bool
            }
            if !(platformSpecifics[MethodCallArguments.presentBadge] is NSNull) && platformSpecifics[MethodCallArguments.presentBadge] != nil {
                presentBadge = platformSpecifics[MethodCallArguments.presentBadge] as! Bool
            }
            if !(platformSpecifics[MethodCallArguments.presentBanner] is NSNull) && platformSpecifics[MethodCallArguments.presentBanner] != nil {
                presentBanner = platformSpecifics[MethodCallArguments.presentBanner] as! Bool
            }
            if !(platformSpecifics[MethodCallArguments.presentList] is NSNull) && platformSpecifics[MethodCallArguments.presentList] != nil {
                presentList = platformSpecifics[MethodCallArguments.presentList] as! Bool
            }
            if let threadIdentifier = platformSpecifics[MethodCallArguments.threadIdentifier] as? String {
                content.threadIdentifier = threadIdentifier
            }
            if let categoryIdentifier = platformSpecifics[MethodCallArguments.categoryIdentifier] as? String {
                content.categoryIdentifier = categoryIdentifier
            }
            if #available(macOS 12.0, *) {
              if let rawInterruptionLevel = platformSpecifics[MethodCallArguments.interruptionLevel] as? UInt {
                content.interruptionLevel = UNNotificationInterruptionLevel.init(rawValue: rawInterruptionLevel)!
              }
            }
            if let attachments = platformSpecifics[MethodCallArguments.attachments] as? [[String: AnyObject]] {
                content.attachments = []
                for attachment in attachments {
                    let identifier = attachment[MethodCallArguments.identifier] as! String
                    let filePath = attachment[MethodCallArguments.filePath] as! String
                    var options: [String: Any] = [:]
                    if let hideThumbnail = attachment[MethodCallArguments.hideThumbnail] as? NSNumber {
                        options[UNNotificationAttachmentOptionsThumbnailHiddenKey] = hideThumbnail
                    }
                    if let thumbnailClippingRect = attachment[MethodCallArguments.attachmentThumbnailClippingRect] as? [String: Any] {
                        let rect = CGRect(x: thumbnailClippingRect["x"] as! Double, y: thumbnailClippingRect["y"] as! Double, width: thumbnailClippingRect["width"] as! Double, height: thumbnailClippingRect["height"] as! Double)
                        options[UNNotificationAttachmentOptionsThumbnailClippingRectKey] = rect.dictionaryRepresentation
                    }
                    let notificationAttachment = try UNNotificationAttachment.init(
                        identifier: identifier,
                        url: URL.init(fileURLWithPath: filePath),
                        options: options
                    )
                    content.attachments.append(notificationAttachment)
                }
            }
        }
        content.userInfo = [MethodCallArguments.payload: arguments[MethodCallArguments.payload] as Any, MethodCallArguments.presentSound: presentSound, MethodCallArguments.presentBadge: presentBadge, MethodCallArguments.presentAlert: presentAlert,
                            MethodCallArguments.presentBanner: presentBanner,
                            MethodCallArguments.presentList: presentList]
        if presentSound && content.sound == nil {
            content.sound = UNNotificationSound.default
        }
        return content
    }

    func buildFlutterError(forMethodCallName methodCallName: String, withError error: Error) -> FlutterError {
        return FlutterError.init(code: "\(methodCallName)_error", message: error.localizedDescription, details: "\(error)")
    }

    @available(macOS 10.14, *)
    func buildUserNotificationCalendarTrigger(fromArguments arguments: [String: AnyObject]) -> UNCalendarNotificationTrigger {
        let scheduledDateTime = arguments[MethodCallArguments.scheduledDateTime] as! String
        let timeZoneName = arguments[MethodCallArguments.timeZoneName] as! String
        let timeZone = TimeZone.init(identifier: timeZoneName)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: scheduledDateTime)!
        var calendar = Calendar.current
        calendar.timeZone = timeZone!
        if let rawDateTimeComponents = arguments[MethodCallArguments.matchDateTimeComponents] as? Int {
            let dateTimeComponents = DateTimeComponents.init(rawValue: rawDateTimeComponents)!
            switch dateTimeComponents {
            case .time:
                let dateComponents = calendar.dateComponents([.day, .hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            case .dayOfWeekAndTime:
                let dateComponents = calendar.dateComponents([ .weekday, .hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            case .dayOfMonthAndTime:
                let dateComponents = calendar.dateComponents([ .day, .hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            case .dateAndTime:
                let dateComponents = calendar.dateComponents([ .day, .month, .hour, .minute, .second, .timeZone], from: date)
                return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
            }
        }
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date)
        return UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    }

    @available(macOS 10.14, *)
    func buildUserNotificationTimeIntervalTrigger(fromArguments arguments: [String: AnyObject]) -> UNTimeIntervalNotificationTrigger {
        let rawRepeatInterval = arguments[MethodCallArguments.repeatInterval] as? Int
        let repeatIntervalMilliseconds = arguments[MethodCallArguments.repeatIntervalMilliseconds] as? Int

        if rawRepeatInterval != nil {
            let repeatInterval = RepeatInterval.init(rawValue: rawRepeatInterval!)!
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
        } else {
            let repeatIntervalSeconds = repeatIntervalMilliseconds! / 1000
            return UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(repeatIntervalSeconds), repeats: true)
        }
    }

    @available(macOS 10.14, *)
    func requestPermissionsImpl(soundPermission: Bool, alertPermission: Bool, badgePermission: Bool, provisionalPermission: Bool, criticalPermission: Bool, result: @escaping FlutterResult) {
        if !soundPermission && !alertPermission && !badgePermission && !provisionalPermission && !criticalPermission {
            result(false)
            return
        }
        var options: UNAuthorizationOptions = []
        if soundPermission {
            options.insert(.sound)
        }
        if alertPermission {
            options.insert(.alert)
        }
        if badgePermission {
            options.insert(.badge)
        }
        if provisionalPermission {
            options.insert(.provisional)
        }
        if criticalPermission {
            options.insert(.criticalAlert)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, _) in
            result(granted)
        }
    }

    func checkPermissions(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let dict = [
                    MethodCallArguments.isNotificationsEnabled: settings.authorizationStatus == .authorized,
                    MethodCallArguments.isSoundEnabled: settings.soundSetting == .enabled,
                    MethodCallArguments.isAlertEnabled: settings.alertSetting == .enabled,
                    MethodCallArguments.isBadgeEnabled: settings.badgeSetting == .enabled,
                    MethodCallArguments.isProvisionalEnabled: settings.authorizationStatus == .provisional,
                    MethodCallArguments.isCriticalEnabled: settings.criticalAlertSetting == .enabled
                ]

                result(dict)
            }
        } else {
            result(nil)
        }
    }

    @available(macOS, introduced: 10.8, deprecated: 11.0)
    func buildNSUserNotification(fromArguments arguments: [String: AnyObject]) -> NSUserNotification {
        let notification = NSUserNotification.init()
        notification.identifier = getIdentifier(fromArguments: arguments)
        if let title = arguments[MethodCallArguments.title] as? String {
            notification.title = title
        }
        if let subtitle = arguments[MethodCallArguments.subtitle] as? String {
            notification.subtitle = subtitle
        }
        if let body = arguments[MethodCallArguments.body] as? String {
            notification.informativeText = body
        }
        var presentSound = false
        if let platformSpecifics = arguments[MethodCallArguments.platformSpecifics] as? [String: AnyObject] {
            if let sound = platformSpecifics[MethodCallArguments.sound] as? String {
                notification.soundName = sound
            }

            if !(platformSpecifics[MethodCallArguments.presentSound] is NSNull) && platformSpecifics[MethodCallArguments.presentSound] != nil {
                presentSound = platformSpecifics[MethodCallArguments.presentSound] as! Bool
            }

        }
        notification.userInfo = [MethodCallArguments.payload: arguments[MethodCallArguments.payload] as Any]
        if presentSound && notification.soundName == nil {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        return notification
    }

    func getIdentifier(fromArguments arguments: [String: AnyObject]) -> String {
        return String(arguments[MethodCallArguments.id] as! Int)
    }

    func handleSelectNotification(notificationId: Int, payload: String?) {
        var arguments: [String: Any?] = [:]
        arguments["notificationId"] = notificationId
        arguments["payload"] = payload
        arguments["notificationResponseType"] = 0
        channel.invokeMethod("didReceiveNotificationResponse", arguments: arguments)
    }

    func handleSelectNotificationAction(arguments: [String: Any?]) {
        channel.invokeMethod("didReceiveNotificationResponse", arguments: arguments)
    }

    @available(macOS 10.14, *)
    func extractNotificationResponseDict(response: UNNotificationResponse) -> [String: Any?] {
        var notificationResponseDict: [String: Any?] = [:]
        notificationResponseDict["notificationId"] = Int(response.notification.request.identifier)!
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            notificationResponseDict[MethodCallArguments.notificationResponseType] = 0
        } else if response.actionIdentifier != UNNotificationDismissActionIdentifier {
            notificationResponseDict[MethodCallArguments.actionId] = response.actionIdentifier
            notificationResponseDict[MethodCallArguments.notificationResponseType] = 1
        }
        notificationResponseDict["input"] = (response as? UNTextInputNotificationResponse)?.userText
        notificationResponseDict[MethodCallArguments.payload] = response.notification.request.content.userInfo[MethodCallArguments.payload]
        return notificationResponseDict
    }

    func isAFlutterLocalNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo[MethodCallArguments.presentAlert] != nil &&
        userInfo[MethodCallArguments.presentSound] != nil &&
        userInfo[MethodCallArguments.presentBadge] != nil && userInfo[MethodCallArguments.payload] != nil
    }
}
