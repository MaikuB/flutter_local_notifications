#include <string>

/// <summary>
/// Defines names of methods of this plugin that are callable
/// through Flutter's method channel.
/// </summary>
namespace Method
{
	extern const std::string INITIALIZE;
	extern const std::string GET_NOTIFICATION_APP_LAUNCH_DETAILS;
	extern const std::string SHOW;
	extern const std::string CANCEL;
	extern const std::string CANCEL_ALL;
	extern const std::string DID_RECEIVE_NOTIFICATION_RESPONSE;
	extern const std::string GET_ACTIVE_NOTIFICATIONS;
}
