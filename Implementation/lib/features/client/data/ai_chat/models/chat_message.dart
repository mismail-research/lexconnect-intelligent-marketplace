import 'lawyer_match.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLawyerCard;
  final List<LawyerMatch> lawyers;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLawyerCard = false,
    this.lawyers = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'isLawyerCard': isLawyerCard,
    'lawyers': lawyers.map((l) => l.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    isLawyerCard: json['isLawyerCard'] as bool? ?? false,
    lawyers: (json['lawyers'] as List<dynamic>? ?? [])
        .map((e) => LawyerMatch.fromJson(e as Map<String, dynamic>))
        .toList(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}