import 'package:fit/models/bot/chat_message.dart';

class Conversation {
  int id;
  int traineeId;
  String traineeName;
  String traineeAvatar;
  String traineeLevel;
  String subscriptionStatus;
  bool planAssigned;
  String planAssignedDate;
  List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.traineeAvatar,
    required this.traineeLevel,
    required this.subscriptionStatus,
    required this.planAssigned,
    required this.planAssignedDate,
    required this.messages,
  });

  int get unreadCount {
    return messages.where((m) => !m.isUser && !(m.isError)).length;
  }

  ChatMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }
}