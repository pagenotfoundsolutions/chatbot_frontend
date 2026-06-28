import '../bloc/conversations_event.dart';
import '../bloc/conversations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../ai_models/presentation/bloc/ai_providers_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/message_role.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../../../ai_models/presentation/widgets/model_selection_widget.dart';

class ChatPage extends StatefulWidget {
  final String? conversationId;
  final bool showBackButton;
  final bool showDrawerButton;
  final VoidCallback? onDrawerTap;

  const ChatPage({
    super.key,
    this.conversationId,
    this.showBackButton = true,
    this.showDrawerButton = false,
    this.onDrawerTap,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _loadConversation();
    }
  }

  void _loadConversation() {
    final currentBlocId = context.read<ChatBloc>().state.conversationId;
    if (widget.conversationId != null) {
      if (currentBlocId != widget.conversationId) {
        context.read<ChatBloc>().add(ChatEvent.opened(widget.conversationId!));
      }
    } else {
      if (currentBlocId != null) {
        context.read<ChatBloc>().add(const ChatEvent.reset());
      }
    }
  }

  void _onScroll() {
    // Assuming list is reversed, scrolling to top means pixels increase
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ChatBloc>().state;
      if (!state.isLoading && !state.isLoadingMore && !state.hasReachedMax) {
        context.read<ChatBloc>().add(
          ChatEvent.loadMessagesRequested(page: state.currentPage + 1),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<ChatBloc, ChatState>(
              listenWhen: (previous, current) => previous.error != current.error,
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!), backgroundColor: theme.colorScheme.error),
                  );
                }
              },
            ),
            BlocListener<ChatBloc, ChatState>(
              listenWhen: (previous, current) => 
                  widget.conversationId == null && 
                  previous.conversationId == null && 
                  current.conversationId != null,
              listener: (context, state) {
                if (state.conversationId != null) {
                  context.read<ConversationsBloc>().add(const ConversationsEvent.getConversationsRequested(page: 1));
                  context.go('/chat/${state.conversationId}');
                }
              },
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showBackButton || widget.showDrawerButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (ctx) => IconButton(
                      icon: Icon(widget.showDrawerButton ? Icons.menu : Icons.arrow_back),
                      onPressed: () {
                        if (widget.showDrawerButton) {
                          widget.onDrawerTap?.call();
                        } else {
                          context.pop();
                        }
                      },
                    ),
                  ),
                ),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) =>
                    previous.messages != current.messages ||
                    previous.isLoading != current.isLoading ||
                    previous.isLoadingMore != current.isLoadingMore ||
                    previous.isSending != current.isSending,
                builder: (context, state) {
                  if (state.isLoading && state.messages.isEmpty) {
                    return const Center(child: AppCircleLoader());
                  }

                  if (state.messages.isEmpty) {
                    if (widget.conversationId == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'What can I help with?',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        'Send a message to start chatting',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Latest message at the bottom
                    itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: AppCircleLoader(),
                          ),
                        );
                      }
                      
                      final message = state.messages[index];
                      // The first message (index 0) in reversed list is the latest.
                      // If we are sending and this is the assistant message being streamed,
                      // mark it as streaming.
                      final isStreamingThis = state.isSending &&
                          index == 0 &&
                          message.role == MessageRole.assistant;
                      return ChatBubble(
                        key: ValueKey(message.id),
                        message: message,
                        isStreaming: isStreamingThis,
                      );
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ModelSelectionWidget(
                onModelSelected: (providerId, modelId, thinkingEnabled) {
                  // Handled by AiProvidersBloc now
                },
              ),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) => previous.isSending != current.isSending,
              builder: (context, state) {
                return ChatInputBar(
                  isLoading: state.isSending,
                  onSend: (text) {
                    final aiState = context.read<AiProvidersBloc>().state;
                    final providerId = aiState.selectedProviderId ?? '';
                    final modelId = aiState.selectedModelId ?? '';
                    final thinkingEnabled = aiState.thinkingEnabled;

                    context.read<ChatBloc>().add(ChatEvent.sendMessageRequested(
                      content: text,
                      providerId: providerId,
                      modelId: modelId,
                      thinkingEnabled: thinkingEnabled,
                    ));
                  },
                  onCancel: () {
                    context.read<ChatBloc>().add(const ChatEvent.cancelGenerationRequested());
                  },
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}}