import 'default_style_information.dart';
import '../person.dart';
import '../message.dart';

/// Used to pass the content for an Android notification displayed using the messaging style.
class MessagingStyleInformation extends DefaultStyleInformation {
  /// The person displayed for any messages that are sent by the user.
  final Person person;

  /// The title to be displayed on this conversation.
  final String conversationTitle;

  /// Whether this conversation notification represents a group.
  final bool groupConversation;

  /// Messages to be displayed by this notification
  final List<Message> messages;

  MessagingStyleInformation(
    this.person, {
    this.conversationTitle,
    this.groupConversation,
    this.messages,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle) {
    assert(this.person?.name != null, 'Must provide the details of the person');
  }

  /// Create a [Map] object that describes the [MessagingStyleInformation] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  @override
  Map<String, dynamic> toMap() {
    var styleJson = super.toMap();
    styleJson['person'] = person.toMap();
    styleJson['conversationTitle'] = conversationTitle;
    styleJson['groupConversation'] = groupConversation;
    styleJson['messages'] = messages?.map((m) => m.toMap())?.toList();
    return styleJson;
  }
}
