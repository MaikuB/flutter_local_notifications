import UserNotifications

public class Converters {
    public static func parseNotificationCategoryOptions(_ options: [AnyHashable]?) -> UNNotificationCategoryOptions {
        var result = Int(UNNotificationCategoryOption.none)

        for option in options ?? [] {
            guard let option = option as? NSNumber else {
                continue
            }
            result |= option.intValue
        }

        return UNNotificationCategoryOptions(rawValue: result)
    }

    public static func parseNotificationActionOptions(_ options: [AnyHashable]?) -> UNNotificationActionOptions {
        var result = Int(UNNotificationActionOption.none)

        for option in options ?? [] {
            guard let option = option as? NSNumber else {
                continue
            }
            result |= option.intValue
        }

        return UNNotificationActionOptions(rawValue: result)
    }
}
