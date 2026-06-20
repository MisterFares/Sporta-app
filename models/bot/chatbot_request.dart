// chatbot_model.dart
class ChatbotResponse {
  final bool isSuccess;
  final String message;
  final String reply; 
  final dynamic errors;

  ChatbotResponse({
    required this.isSuccess,
    required this.message,
    required this.reply,
    this.errors,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
       reply: json['reply']?.toString() ?? '',
      errors: json['errors'],
    );
  }
}