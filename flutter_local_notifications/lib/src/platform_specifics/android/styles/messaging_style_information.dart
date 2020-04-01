import 'default_style_information.dart';
import '../person.dart';
import '../message.dart';

/// Used to pass the content for an Android notification displayed using the messaging style.
class MessagingStyleInformation extends DefaultStyleInformation {
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

  /// The person displayed for any messages that are sent by the user.
  final Person person;

  /// The title to be displayed on this conversation.
  final String conversationTitle;

  /// Whether this conversation notification represents a group.
  final bool groupConversation;

  /// Messages to be displayed by this notification
  final List<Message> messages;

  /// Creates a [Map] object that describes the [MessagingStyleInformation] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll(<String, dynamic>{
        'person': person.toMap(),
        'conversationTitle': conversationTitle,
        'groupConversation': groupConversation,
        'messages': messages?.map((m) => m.toMap())?.toList()
      });
  }
}
