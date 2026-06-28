import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/conversation.dart';

class ConversationListTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, yy').format(conversation.updatedAt.toLocal());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: isSelected ? AppColors.primaryAccent.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: isSelected 
                  ? Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.5))
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryAccent.withValues(alpha: 0.2)
                        : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 18.r,
                    color: isSelected ? AppColors.primaryAccent : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title.isNotEmpty ? conversation.title : 'New Chat',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryAccent : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null || onRename != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 20.r, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    onSelected: (value) {
                      if (value == 'rename' && onRename != null) {
                        onRename!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onRename != null)
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18.r, color: theme.colorScheme.primary),
                              SizedBox(width: 12.w),
                              Text('Rename', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18.r, color: theme.colorScheme.error),
                              SizedBox(width: 12.w),
                              Text('Delete', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
