import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_role.dart';
import 'code_block_builder.dart';

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
        left: isUser ? 32.w : 8.w,
        right: isUser ? 8.w : 32.w,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme, isUser: false),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.90,
                      ),
                      padding: context.responsive.value(
                        mobile: () => EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        tablet: () => EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        desktop: () => EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primaryAccent
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: isUser
                              ? Radius.circular(20.r)
                              : Radius.circular(4.r),
                          bottomRight: isUser
                              ? Radius.circular(4.r)
                              : Radius.circular(20.r),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? AppColors.primaryAccent.withValues(
                                    alpha: 0.25,
                                  )
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildContent(context, theme, isUser),
                    ),
                    if (message.content.isNotEmpty && !isStreaming)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: message.content),
                            );
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
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
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
            SizedBox(width: 8.w),
            _buildAvatar(theme, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isUser) {
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
    if (message.content.isEmpty &&
        (message.thinkingContent == null || message.thinkingContent!.isEmpty)) {
      // Show animated typing dots instead of a blocking loader
      return const _TypingIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.thinkingContent != null &&
            message.thinkingContent!.isNotEmpty)
          _buildThinkingContent(theme, message.thinkingContent!),
        if (message.content.isNotEmpty)
          MarkdownBody(
            data: message.content,
            selectable:
                false, // Prevent all-text selection highlighting, use explicit copy inside code block
            builders: {'code': CodeBlockBuilder(context)},
            styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
            styleSheet: MarkdownStyleSheet(
              p: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
              code: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                backgroundColor: Colors.transparent,
                fontFamily: 'monospace',
              ),
              codeblockDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              blockquote: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primaryAccent, width: 4.w),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThinkingContent(ThemeData theme, String thinkingContent) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        dense: true,
        iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        collapsedIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        title: Text(
          'Thinking process',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: MarkdownBody(
              data: thinkingContent,
              selectable: true,
              styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
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
        radius: 12.r,
        backgroundColor: isUser
            ? AppColors.primaryAccent.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        child: Icon(
          isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
          size: 14.r,
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
      return Tween<double>(
        begin: 0,
        end: -6,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
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
