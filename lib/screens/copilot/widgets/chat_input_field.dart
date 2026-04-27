import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  bool _hasText = false;
  late AnimationController _sendAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _sendAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _sendAnim, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendAnim.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendAnim.forward();
      } else {
        _sendAnim.reverse();
      }
    }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isEmpty) return;
    widget.onSend(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom > 0 ? bottom + 8 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3EE),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: widget.maxCharacters,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask about your finances…',
                  hintStyle: TextStyle(color: Color(0xFFAFB8C4), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  counterText: '',
                ),
                onSubmitted: (_) {
                  if (_hasText) _handleSend();
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          ScaleTransition(
            scale: _scaleAnim,
            child: GestureDetector(
              onTap: _hasText ? _handleSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hasText ? AppColors.secondary : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  boxShadow: _hasText
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _hasText ? Colors.white : const Color(0xFFCBD5E1),
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
