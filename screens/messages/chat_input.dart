import 'dart:io';

import 'package:fit/models/chat/chat.dart';
import 'package:fit/screens/messages/chat_attachment_menu.dart';
import 'package:fit/screens/messages/chat_attachment_preview.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatInput extends StatefulWidget {
  final String value;
  final Function(String) onChange;
  final Function(File?)? onSend;
  final ChatMessage? editMsg;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const ChatInput({
    super.key,
    required this.value,
    required this.onChange,
    required this.onSend,
    this.editMsg,
    required this.controller,
    this.focusNode,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _showAttachMenu = false;
  final List<XFile> _attachments = [];
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.value;
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _textController.text = widget.value;
    }
  }

  void _handleSend() {
    if (_textController.text.trim().isNotEmpty || _attachments.isNotEmpty) {
      final attachmentFile = _attachments.isNotEmpty
          ? File(_attachments.first.path)
          : null;
      widget.onSend?.call(attachmentFile);
      _attachments.clear();
      _textController.clear();
      widget.onChange('');
    }
  }

  Future<void> _pickMedia() async {
  final List<XFile> media = await _picker.pickMultiImage();
  if (media.isNotEmpty) {
    setState(() {
      _attachments.addAll(media);
    });
  }
  
  // Also allow picking a video
  final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
  if (video != null) {
    setState(() {
      _attachments.add(video);
    });
  }
}

  Future<void> _pickDocument() async {
    final FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      final file = XFile(result.files.single.path!);
      setState(() {
        _attachments.add(file);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          if (_attachments.isNotEmpty)
            ChatAttachmentPreview(
              attachments: _attachments,
              onRemove: (index) => setState(() => _attachments.removeAt(index)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Attach button
                GestureDetector(
                  onTap: () =>
                      setState(() => _showAttachMenu = !_showAttachMenu),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.plus,
                      size: 24,
                      color: _showAttachMenu
                          ? AppColors.textPrimary
                          : AppColors.cardTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: widget.focusNode,
                    style: TextStyle(color: AppColors.textPrimary),
                    maxLines: null,
                    onChanged: widget.onChange,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(
                        color: AppColors.cardTextSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                // Send button
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.send,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Attachment menu
          if (_showAttachMenu)
            ChatAttachmentMenu(
              isOpen: _showAttachMenu,
              onClose: () => setState(() => _showAttachMenu = false),
              onSelectMedia: () {
                _pickMedia();
                setState(() => _showAttachMenu = false);
              },
              onSelectDoc: () {
                _pickDocument();
                setState(() => _showAttachMenu = false);
              },
            ),
        ],
      ),
    );
  }
}