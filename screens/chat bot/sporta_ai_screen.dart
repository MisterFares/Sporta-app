import 'dart:collection';
import 'package:fit/models/bot/chat_message.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/screens/chat%20bot/build_input_bar.dart';
import 'package:fit/screens/chat%20bot/build_message_bubble.dart';
import 'package:fit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

class SportaAIScreen extends StatefulWidget {
  const SportaAIScreen({super.key});

  @override
  State<SportaAIScreen> createState() => _SportaAIScreenState();
}

class _SportaAIScreenState extends State<SportaAIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final Queue<String> _messageQueue = Queue<String>();

  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "👋 Hi! I'm Sporta AI.\n\n"
            "How can I help you today?",
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading || _isProcessing) {
      if (_isProcessing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please wait, still processing previous message'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isProcessing = true;
      _isLoading = true;
    });

    _scrollToBottom();

    _sendToBackend(message);
  }

  Future<void> _sendToBackend(String message) async {
    try {
      final response = await ApiService.askChatbot(message);

      setState(() {
        if (response.isSuccess) {
          _messages.add(
            ChatMessage(
              text: response.reply, // 👈 AI response
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              text: 'Sorry, I could not process your request.',
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
        }
        _isLoading = false;
        _isProcessing = false;
      });

      _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        drawerIcon: Icons.menu,
        title: 'Sporta AI',
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: Icon(Icons.delete_outline, color: AppColors.red),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      drawer: AppDrawer(selectedIndex: 7, role: 'trainee'),
      body: Column(
        children: [

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
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
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
        title: Text(
          'Clear Chat',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
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
