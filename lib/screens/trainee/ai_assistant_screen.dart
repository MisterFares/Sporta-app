// screens/ai_assistant_screen.dart
import 'dart:collection';

import 'package:fit/classes/messages/chat_message.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/components/mesages/build_input_bar.dart';
import 'package:fit/components/mesages/build_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final Queue<String> _messageQueue = Queue<String>();

  bool _isLoading = false;
  bool _isProcessing = false;

  // Rate limiting
  static const int _maxRetries = 3;

  // Replace with your actual Gemini API key
  static const String _apiKey = "AIzaSyBnt6WEqNjqR2hlfK20goQaFLnNWg5oCpM";
  static const String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "👋 Hi! I'm your AI fitness assistant.\n\n"
            "I can help you with:\n"
            "• 💪 Workout plans\n"
            "• 🥗 Nutrition advice\n"
            "• 📊 Progress tracking\n"
            "• ❓ Answer fitness questions\n\n"
            "Note: Please wait a few seconds between messages.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading || _isProcessing) {
      if (_isProcessing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait, still processing previous message'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Clear input
    _messageController.clear();

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isProcessing = true;
      _isLoading = true;
    });

    _scrollToBottom();

    // Process message
    _sendWithRetry(message, 0);
  }

  Future<void> _sendWithRetry(String message, int retryCount) async {
    if (retryCount >= _maxRetries) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "❌ I'm having trouble connecting right now. Please try again in a minute.\n\n"
                "This usually happens due to high demand. The free tier has limits.",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
        _isProcessing = false;
      });
      return;
    }

    try {
      final prompt = _buildPromptWithContext(message);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 1024, // Reduced to save tokens
        },
      };

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add(
            ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
          _isProcessing = false;
        });

        _scrollToBottom();
      } else if (response.statusCode == 429) {
        // Rate limit - calculate backoff time
        final delay = Duration(seconds: (retryCount + 1) * 3);

        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  "⏳ Rate limit reached. Waiting ${delay.inSeconds} seconds before retrying...",
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
        });

        await Future.delayed(delay);
        _sendWithRetry(message, retryCount + 1);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']['message'] ?? 'Unknown error');
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "⚠️ Error: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
        _isProcessing = false;
      });
    }
  }

  String _buildPromptWithContext(String userMessage) {
    // Only get last 2 exchanges to save tokens
    final recentMessages = _messages.reversed
        .take(6)
        .toList()
        .reversed
        .toList();

    String context = "";
    for (var msg in recentMessages) {
      if (!msg.isUser && msg.text.isNotEmpty && !msg.text.contains("👋 Hi!")) {
        context +=
            "Assistant: ${msg.text.substring(0, msg.text.length > 200 ? 200 : msg.text.length)}\n";
      } else if (msg.isUser && msg.text.isNotEmpty) {
        context += "User: ${msg.text}\n";
      }
    }

    return """
You are a fitness assistant. Be helpful, concise (2-3 sentences max when possible).

Context:
$context

User: $userMessage

Assistant: 
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'AI Assistant',
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      drawer: AppDrawer(selectedIndex: 7, role: 'trainee'),
      body: Column(
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Free API has rate limits. Please wait 3-5 seconds between messages.',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return buildMessageBubble(message, context);
              },
            ),
          ),

          // Typing Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI is thinking...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          buildInputBar(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
            isProcessing: _isProcessing,
            hintText: 'Ask the AI...',
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Clear the conversation history?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          textButton(
            14,
            AppColors.textSecondary,
            'Cancel',
            () => Navigator.pop(context),
          ),
          textButton(14, AppColors.red, 'Clear', () {
            setState(() {
              _messages.clear();
              _addWelcomeMessage();
              _messageQueue.clear();
              _isProcessing = false;
              _isLoading = false;
              Navigator.pop(context);
            });
          }),
        ],
      ),
    );
  }
}
