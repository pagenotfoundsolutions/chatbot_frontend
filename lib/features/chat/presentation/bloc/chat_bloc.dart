import '../../domain/usecases/create_conversation.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/message.dart';
import '../../domain/entities/message_role.dart';
import '../../domain/entities/chat_stream_event.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/stream_message.dart';
import '../../domain/usecases/cancel_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final StreamMessageUseCase streamMessageUseCase;
  final CancelMessageUseCase cancelMessageUseCase;
  final CreateConversationUseCase createConversationUseCase;
  CancelToken? _cancelToken;

  ChatBloc({
    required this.getMessagesUseCase,
    required this.streamMessageUseCase,
    required this.cancelMessageUseCase,
    required this.createConversationUseCase,
  }) : super(const ChatState()) {
    on<ChatEventOpened>(_onOpened);
    on<ChatEventReset>(_onReset);
    on<ChatEventLoadMessagesRequested>(_onLoadMessagesRequested);
    on<ChatEventSendMessageRequested>(_onSendMessageRequested);
    on<ChatEventCancelGenerationRequested>(_onCancelGenerationRequested);
  }

  void _onCancelGenerationRequested(
    ChatEventCancelGenerationRequested event,
    Emitter<ChatState> emit,
  ) {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User cancelled');
      _cancelToken = null;
    }
    
    if (state.conversationId != null) {
      cancelMessageUseCase(CancelMessageParams(conversationId: state.conversationId!));
    }
    
    emit(state.copyWith(isSending: false));
  }

  void _onReset(ChatEventReset event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }

  void _onOpened(ChatEventOpened event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      conversationId: event.conversationId,
      messages: [],
      isLoading: true,
      hasReachedMax: false,
      currentPage: 1,
      error: null,
    ));
    add(const ChatEvent.loadMessagesRequested(page: 1));
  }

  Future<void> _onLoadMessagesRequested(
    ChatEventLoadMessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversationId == null) return;

    if (event.page == 1) {
      emit(state.copyWith(isLoading: true, error: null));
    } else {
      if (state.hasReachedMax) return;
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final result = await getMessagesUseCase(
      GetMessagesParams(
        conversationId: state.conversationId!,
        page: event.page,
        size: 10,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        ));
      },
      (pageResp) {
        final newItems = pageResp.items;
        final hasReachedMax = event.page >= pageResp.pages;
        // The API returns messages ordered chronologically or reverse?
        // Let's assume chronological. We will prepend/append depending on ListView orientation.
        // Usually, chat UI ListView is reversed so the latest is at the bottom.
        // We will assume the UI reverses it, or we handle it here.
        final messages = event.page == 1 
            ? newItems 
            : [...state.messages, ...newItems];

        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          messages: messages,
          hasReachedMax: hasReachedMax,
          currentPage: event.page,
        ));
      },
    );
  }

  Future<void> _onSendMessageRequested(
    ChatEventSendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    String? currentConversationId = state.conversationId;

    if (currentConversationId == null) {
      final title = event.content.length > 80 ? '${event.content.substring(0, 77)}...' : event.content;
      final createResult = await createConversationUseCase(
        CreateConversationParams(title: title),
      );
      
      bool createFailed = false;
      createResult.fold(
        (failure) {
          emit(state.copyWith(error: failure.message));
          createFailed = true;
        },
        (conversation) {
          currentConversationId = conversation.id;
          emit(state.copyWith(conversationId: conversation.id));
        },
      );
      if (createFailed || currentConversationId == null) return;
    }

    // Optimistic Update
    final tempUserMessageId = const Uuid().v4();
    final userMessage = Message(
      id: tempUserMessageId,
      role: MessageRole.user,
      content: event.content,
      createdAt: DateTime.now().toUtc(),
    );

    final tempAssistantMessageId = const Uuid().v4();
    final tempAssistantMessage = Message(
      id: tempAssistantMessageId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now().toUtc(),
    );

    emit(state.copyWith(
      isSending: true,
      error: null,
      messages: [tempAssistantMessage, userMessage, ...state.messages],
    ));

    _cancelToken = CancelToken();

    final stream = streamMessageUseCase(
      StreamMessageParams(
        conversationId: currentConversationId!,
        content: event.content,
        providerId: event.providerId,
        modelId: event.modelId,
        thinkingEnabled: event.thinkingEnabled,
        cancelToken: _cancelToken,
      ),
    );

    String accumulatedText = '';
    String accumulatedThinkingText = '';
    DateTime lastEmitTime = DateTime.fromMillisecondsSinceEpoch(0); // Force first token to always emit
    bool hasEmittedFirstToken = false;
    bool hasStartedThinking = false;

    // Helper: build an updated messages list with the assistant message content replaced
    List<Message> _updateAssistantMessage(String newContent, {String? newThinkingContent}) {
      final idx = state.messages.indexWhere((m) => m.id == tempAssistantMessageId);
      if (idx == -1) return state.messages;
      final updated = List<Message>.of(state.messages);
      updated[idx] = updated[idx].copyWith(
        content: newContent,
        thinkingContent: newThinkingContent ?? updated[idx].thinkingContent,
      );
      return updated;
    }

    await emit.forEach(
      stream,
      onData: (result) {
        return result.fold(
          (failure) {
            return state.copyWith(
              isSending: false,
              messages: _updateAssistantMessage('$accumulatedText\n\n[Error: ${failure.message}]'),
              error: failure.message,
            );
          },
          (streamEvent) {
            return switch (streamEvent) {
              ChatStreamEventToken(:final content) => () {
                accumulatedText += content;
                final now = DateTime.now();
                if (!hasEmittedFirstToken || now.difference(lastEmitTime).inMilliseconds >= 30) {
                  lastEmitTime = now;
                  hasEmittedFirstToken = true;
                  return state.copyWith(
                    messages: _updateAssistantMessage(accumulatedText, newThinkingContent: accumulatedThinkingText.isNotEmpty ? accumulatedThinkingText : null),
                  );
                }
                return state;
              }(),
              ChatStreamEventThinking(:final content) => () {
                hasStartedThinking = true;
                accumulatedThinkingText += content;
                final now = DateTime.now();
                if (!hasEmittedFirstToken || now.difference(lastEmitTime).inMilliseconds >= 30) {
                  lastEmitTime = now;
                  hasEmittedFirstToken = true;
                  return state.copyWith(
                    messages: _updateAssistantMessage(accumulatedText, newThinkingContent: accumulatedThinkingText),
                  );
                }
                return state;
              }(),
              ChatStreamEventDone() => () {
                return state.copyWith(
                  isSending: false,
                  messages: _updateAssistantMessage(accumulatedText, newThinkingContent: accumulatedThinkingText.isNotEmpty ? accumulatedThinkingText : null),
                );
              }(),
              ChatStreamEventError(:final detail) => () {
                return state.copyWith(
                  isSending: false,
                  messages: _updateAssistantMessage('$accumulatedText\n\n[Error: $detail]'),
                  error: detail,
                );
              }(),
            };
          },
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          isSending: false,
          error: error.toString(),
        );
      },
    );
  }
}
