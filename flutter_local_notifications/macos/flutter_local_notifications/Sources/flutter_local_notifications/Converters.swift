import UserNotifications

public class Converters {
    public static func parseNotificationCategoryOptions(_ options: [Any]?) -> UNNotificationCategoryOptions {
        var result: UInt = 0

        for option in options ?? [] {
            guard let option = option as? NSNumber else {
                continue
            }
            result |= option.uintValue
        }

        return UNNotificationCategoryOptions(rawValue: result)
    }

    public static func parseNotificationActionOptions(_ options: [Any]?) -> UNNotificationActionOptions {
        var result: UInt = 0

        for option in options ?? [] {
            guard let option = option as? NSNumber else {
                continue
            }
            result |= option.uintValue
        }

        return UNNotificationActionOptions(rawValue: result)
    }
}
