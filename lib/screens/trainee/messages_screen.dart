// screens/coach/messages_screen.dart
import 'package:fit/classes/messages/chat_message.dart';
import 'package:fit/classes/messages/conversation.dart';
import 'package:fit/components/mesages/build_input_bar.dart';
import 'package:fit/components/mesages/build_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

const int currentUserId = 1;
const String currentUserName = "Michael Jenkins";

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Conversation> _conversations = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _conversations = [
      Conversation(
        id: 1,
        traineeId: 101,
        traineeName: "John Doe",
        traineeAvatar:
            "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop",
        traineeLevel: "Intermediate",
        subscriptionStatus: "Active",
        planAssigned: true,
        planAssignedDate: "2024-03-15",
        messages: [
          ChatMessage(
            text: "Hi Coach! I have a question about my squat form.",
            isUser: false,
            timestamp: DateTime(2024, 3, 16, 10, 30),
            senderId: 101,
            senderName: "John Doe",
          ),
          ChatMessage(
            text: "Sure! Send me a video and I'll review it.",
            isUser: true,
            timestamp: DateTime(2024, 3, 16, 10, 35),
            senderId: currentUserId,
            senderName: currentUserName,
          ),
          ChatMessage(
            text: "Here it is. I feel like my depth is off.",
            isUser: false,
            timestamp: DateTime(2024, 3, 16, 14, 20),
            senderId: 101,
            senderName: "John Doe",
          ),
        ],
      ),
      Conversation(
        id: 2,
        traineeId: 102,
        traineeName: "Sarah Williams",
        traineeAvatar:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop",
        traineeLevel: "Beginner",
        subscriptionStatus: "Active",
        planAssigned: true,
        planAssignedDate: "2024-03-10",
        messages: [
          ChatMessage(
            text: "Coach, can you review my meal plan?",
            isUser: false,
            timestamp: DateTime(2024, 3, 17, 9, 0),
            senderId: 102,
            senderName: "Sarah Williams",
            isError: false,
          ),
          ChatMessage(
            text: "Yes, I'll send you updated macros today.",
            isUser: true,
            timestamp: DateTime(2024, 3, 17, 9, 15),
            senderId: currentUserId,
            senderName: currentUserName,
            isError: false,
          ),
        ],
      ),
    ];
  }

  void _sendMessage(Conversation conversation, Function setDialogState) {
  final content = _messageController.text.trim();
  if (content.isEmpty) return;

  if (!conversation.planAssigned) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Messaging not enabled. Trainee needs a plan assigned first.'),
        backgroundColor: AppColors.red,
      ),
    );
    return;
  }

  final newMessage = ChatMessage(
    text: content,
    isUser: true,
    timestamp: DateTime.now(),
    senderId: currentUserId,
    senderName: currentUserName,
    isError: false,
  );

  setDialogState(() {
    conversation.messages.add(newMessage);
    _messageController.clear();
    _isProcessing = true;
  });

  _scrollToBottom();

  // Simulate reply
  _simulateReply(conversation, setDialogState);
}

  void _simulateReply(Conversation conversation, Function setDialogState) {
  final replies = [
    "Thanks for the update! I'll review it.",
    "Great progress! Keep it up 💪",
    "I'll adjust my program accordingly.",
    "Let me know if you have any questions.",
    "I see my form is improving!",
    "My consistency is paying off!",
  ];
  final randomReply = replies[DateTime.now().millisecondsSinceEpoch % replies.length];

  Future.delayed(const Duration(seconds: 2), () {
    final replyMessage = ChatMessage(
      text: randomReply,
      isUser: false,
      timestamp: DateTime.now(),
      senderId: conversation.traineeId,
      senderName: conversation.traineeName,
      isError: false,
    );

    setDialogState(() {
      conversation.messages.add(replyMessage);
      _isProcessing = false;
    });

    _scrollToBottom();
  });
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messagesScrollController.hasClients) {
        _messagesScrollController.animateTo(
          _messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openChatDialog(Conversation conversation) {
    _messageController.clear();
    _isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Dialog Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.cardBorder),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            conversation.traineeAvatar,
                          ),
                          backgroundColor: const Color(0xFF2A3036),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.traineeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                conversation.traineeLevel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Messages Area
                  Expanded(
                    child: ListView.builder(
                      controller: _messagesScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: conversation.messages.length,
                      itemBuilder: (context, index) {
                        final message = conversation.messages[index];
                        return buildMessageBubble(message, context);
                      },
                    ),
                  ),

                  // Input Bar
                  buildInputBar(
                    controller: _messageController,
                    onSend: () {
                      _sendMessage(
                        conversation,
                        setDialogState,
                      ); // Pass setDialogState
                    },
                    isLoading: false,
                    isProcessing: _isProcessing,
                    hintText: 'Type your message...',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) {
      _messageController.clear();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Messages'),
      backgroundColor: const Color(0xFF0B0F0E),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                return _buildConversationCard(conv);
              },
            ),
    );
  }

  Widget _buildConversationCard(Conversation conv) {
    final lastMsg = conv.lastMessage;
    final unread = conv.unreadCount;

    return GestureDetector(
      onTap: () => _openChatDialog(conv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(conv.traineeAvatar),
              backgroundColor: const Color(0xFF2A3036),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conv.traineeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (conv.planAssigned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greeen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greeen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg != null
                        ? (lastMsg.isUser ? 'You: ' : '') +
                              (lastMsg.text.length > 50
                                  ? '${lastMsg.text.substring(0, 50)}...'
                                  : lastMsg.text)
                        : 'No messages yet',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          lastMsg != null && !lastMsg.isUser && !lastMsg.isError
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Time and Unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lastMsg != null)
                  Text(
                    DateFormat('h:mm a').format(lastMsg.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (unread > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When trainees subscribe and are assigned a plan,\nthey will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
