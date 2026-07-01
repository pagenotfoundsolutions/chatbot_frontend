import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../bloc/conversations_state.dart';
import '../widgets/conversation_list_tile.dart';

class ConversationsPage extends StatefulWidget {
  final bool isSidebar;
  final String? activeConversationId;
  final Function(String)? onConversationTap;

  const ConversationsPage({
    super.key,
    this.isSidebar = false,
    this.activeConversationId,
    this.onConversationTap,
  });

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final convState = context.read<ConversationsBloc>().state;
    if (convState.conversations.isEmpty && !convState.isLoading) {
      context.read<ConversationsBloc>().add(const ConversationsEvent.getConversationsRequested());
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ConversationsBloc>().state;
      if (!state.isLoading && !state.isLoadingMore && !state.hasReachedMax) {
        context.read<ConversationsBloc>().add(
          ConversationsEvent.getConversationsRequested(page: state.currentPage + 1),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showRenameDialog(BuildContext context, String id, String currentTitle) {
    final bloc = context.read<ConversationsBloc>();
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                bloc.add(
                  ConversationsEvent.updateConversationRequested(id, newTitle),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    final bloc = context.read<ConversationsBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              bloc.add(
                ConversationsEvent.deleteConversationRequested(id),
              );
              Navigator.pop(context);
              if (!widget.isSidebar) {
                // If we are on mobile full page, maybe pop back
                // Or let the bloc listener handle it if needed
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.isSidebar ? theme.colorScheme.surface : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Knowledge Base',
            onPressed: () {
              if (widget.isSidebar && Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                Navigator.of(context).pop();
              }
              context.go('/files');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              if (widget.isSidebar && Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                Navigator.of(context).pop();
              }
              context.go('/profile');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.isSidebar && Scaffold.maybeOf(context)?.isDrawerOpen == true) {
            Navigator.of(context).pop();
          }
          context.go('/home');
        },
        backgroundColor: AppColors.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ConversationsBloc, ConversationsState>(
        listenWhen: (previous, current) => previous.error != current.error,
        buildWhen: (previous, current) =>
            previous.conversations != current.conversations ||
            previous.isLoading != current.isLoading ||
            previous.isLoadingMore != current.isLoadingMore,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: theme.colorScheme.error),
            );
          }
          // If a new conversation was created and we are not in sidebar, we might want to navigate
          // But it's better handled at a higher level or by selecting the first item
        },
        builder: (context, state) {
          if (state.isLoading && state.conversations.isEmpty) {
            return const Center(child: AppCircleLoader());
          }

          if (state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64.r, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  SizedBox(height: 16.h),
                  Text(
                    'No chats yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.isSidebar && Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                        Navigator.of(context).pop();
                      }
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                    child: const Text('Start Chatting', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConversationsBloc>().add(const ConversationsEvent.getConversationsRequested(page: 1));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.conversations.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.conversations.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: AppCircleLoader(),
                    ),
                  );
                }

                final conv = state.conversations[index];
                return ConversationListTile(
                  conversation: conv,
                  isSelected: conv.id == widget.activeConversationId,
                  onTap: () {
                    if (widget.onConversationTap != null) {
                      widget.onConversationTap!(conv.id);
                    } else {
                      context.go('/chat/${conv.id}');
                    }
                  },
                  onRename: () => _showRenameDialog(context, conv.id, conv.title),
                  onDelete: () => _showDeleteDialog(context, conv.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
