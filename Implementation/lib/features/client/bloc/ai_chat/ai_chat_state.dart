import '../../data/ai_chat/models/chat_message.dart';

class AIChatState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final List<String> shownLawyerIds;
  final String? lastLawyerType;
  final RagStatus ragStatus;

  const AIChatState({
    this.messages = const [],
    this.isAiTyping = false,
    this.shownLawyerIds = const [],
    this.lastLawyerType,
    this.ragStatus = RagStatus.idle,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    List<String>? shownLawyerIds,
    String? lastLawyerType,
    RagStatus? ragStatus,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      shownLawyerIds: shownLawyerIds ?? this.shownLawyerIds,
      lastLawyerType: lastLawyerType ?? this.lastLawyerType,
      ragStatus: ragStatus ?? this.ragStatus,
    );
  }
}

enum RagStatus {
  idle,
  embedding,
  searching,
  generating,
}