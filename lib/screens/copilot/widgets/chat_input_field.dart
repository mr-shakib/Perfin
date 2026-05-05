import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
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
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
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
      hasText ? _sendAnim.forward() : _sendAnim.reverse();
    }
  }

  void _handleSend() {
    if (!_hasText) return;
    widget.onSend(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8E5DC), width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPad > 0 ? bottomPad + 6 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F1ED),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFDEDCD6), width: 1),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A2333),
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask about your finances…',
                  hintStyle: TextStyle(
                    color: Color(0xFFADB3BE),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  counterText: '',
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          ScaleTransition(
            scale: _scaleAnim,
            child: GestureDetector(
              onTap: _handleSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hasText ? AppColors.primary : const Color(0xFFE4E2DC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _hasText ? Colors.white : const Color(0xFFBBB8B0),
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
