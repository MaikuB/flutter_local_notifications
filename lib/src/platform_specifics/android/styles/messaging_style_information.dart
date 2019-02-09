part of flutter_local_notifications;

class MessagingStyleInformation extends DefaultStyleInformation {
  final Person person;
  final String conversationTitle;
  final bool groupConversation;
  final List<Message> messages;
  MessagingStyleInformation(this.person,
      {this.conversationTitle,
      this.groupConversation,
      this.messages,
      bool htmlFormatContent: false,
      bool htmlFormatTitle: false})
      : super(htmlFormatContent, htmlFormatTitle) {
    assert(this.person?.name != null, 'Must provide the details of the person');
  }

  Map<String, dynamic> toMap() {
    var styleJson = super.toMap();
    styleJson['person'] = person.toMap();
    styleJson['conversationTitle'] = conversationTitle;
    styleJson['groupConversation'] = groupConversation;
    styleJson['messages'] = messages?.map((m) => m.toMap())?.toList();
    return styleJson;
  }
}
