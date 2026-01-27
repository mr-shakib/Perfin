import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Multi-line text input with send button
/// Requirements: 6.2
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final int maxCharacters;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.maxCharacters = 1000,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isEmpty) return;
    widget.onSend(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 44,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: AppColors.creamLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: widget.maxCharacters,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ask about your finances...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  counterText: '',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                onSubmitted: (_) {
                  // Allow Shift+Enter for new line, Enter alone sends
                  if (_hasText) {
                    _handleSend();
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Send button
          GestureDetector(
            onTap: _hasText ? _handleSend : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText 
                    ? const Color(0xFF1A1A1A) 
                    : AppColors.creamLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_upward,
                color: _hasText ? Colors.white : const Color(0xFF999999),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
