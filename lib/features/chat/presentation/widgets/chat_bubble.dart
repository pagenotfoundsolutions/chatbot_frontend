import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_role.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;

    if (isSystem) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              message.content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 8.h,
        bottom: 8.h,
        left: isUser ? 60.w : 16.w,
        right: isUser ? 16.w : 60.w,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme, isUser: false),
            SizedBox(width: 12.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? AppColors.primaryAccent 
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: isUser ? Radius.circular(20.r) : Radius.circular(4.r),
                      bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(20.r),
                    ),
                    border: isUser ? null : Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser 
                            ? AppColors.primaryAccent.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildContent(theme, isUser),
                ),
                if (message.content.isNotEmpty && !isStreaming)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: message.content));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16.r,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 12.w),
            _buildAvatar(theme, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isUser) {
    if (isUser) {
      return Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          height: 1.4,
        ),
      );
    }

    // Assistant message
    if (message.content.isEmpty) {
      // Show animated typing dots instead of a blocking loader
      return const _TypingIndicator();
    }

    // Render full Markdown (even during streaming as requested by user)
    return MarkdownBody(
      data: message.content,
      selectable: true,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
        code: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E) 
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primaryAccent,
              width: 4.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {required bool isUser}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isUser 
                ? AppColors.primaryAccent.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 16.r,
        backgroundColor: isUser 
            ? AppColors.primaryAccent.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        child: Icon(
          isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
          size: 18.r,
          color: isUser ? AppColors.primaryAccent : theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Animated typing indicator (three bouncing dots)
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: child,
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
