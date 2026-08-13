import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String>? onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;

  const MessageInput({
    super.key,
    this.onSend,
    this.onAttachment,
    this.onVoice,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _hasText => _controller.text.trim().isNotEmpty;

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    widget.onSend?.call(message);
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: widget.onAttachment,
            icon: const Icon(
              Icons.attach_file_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Attach file',
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 46,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _hasText ? _sendMessage : widget.onVoice,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  _hasText ? Icons.send_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}