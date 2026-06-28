import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import '../../../../core/theme/colors.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: widget.isLoading ? widget.onCancel : _handleSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.r,
                width: 48.r,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isLoading 
                      ? [Colors.redAccent, Colors.redAccent.withValues(alpha: 0.8)]
                      : [AppColors.primaryAccent, AppColors.primaryAccent.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(widget.isLoading ? 12.r : 50.r),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isLoading ? Colors.redAccent : AppColors.primaryAccent).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isLoading ? Icons.stop_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
