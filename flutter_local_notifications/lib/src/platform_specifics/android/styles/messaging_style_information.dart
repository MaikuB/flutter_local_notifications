import '../message.dart';
import '../person.dart';
import 'default_style_information.dart';

/// Used to pass the content for an Android notification displayed using the
/// messaging style.
class MessagingStyleInformation extends DefaultStyleInformation {
  /// Constructs an instance of [MessagingStyleInformation].
  MessagingStyleInformation(
    this.person, {
    this.conversationTitle,
    this.groupConversation,
    this.messages,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  /// The person displayed for any messages that are sent by the user.
  final Person person;

  /// The title to be displayed on this conversation.
  final String? conversationTitle;

  /// Whether this conversation notification represents a group.
  final bool? groupConversation;

  /// Messages to be displayed by this notification
  final List<Message>? messages;
}
