abstract class AIChatEvent {}

class LoadInitialChat extends AIChatEvent {}

class SendMessage extends AIChatEvent {
  final String text;
  SendMessage(this.text);
}

class SendLegalCaseQuery extends AIChatEvent {
  final String text;
  SendLegalCaseQuery(this.text);
}

class FetchMoreLawyers extends AIChatEvent {}

class PurgeExpiredSession extends AIChatEvent {}

class DeleteConversation extends AIChatEvent {}