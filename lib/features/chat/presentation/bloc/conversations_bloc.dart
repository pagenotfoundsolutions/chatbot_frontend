import 'package:bloc/bloc.dart';
import '../../domain/usecases/create_conversation.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/update_conversation.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final GetConversationsUseCase getConversationsUseCase;
  final CreateConversationUseCase createConversationUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final UpdateConversationUseCase updateConversationUseCase;

  ConversationsBloc({
    required this.getConversationsUseCase,
    required this.createConversationUseCase,
    required this.deleteConversationUseCase,
    required this.updateConversationUseCase,
  }) : super(const ConversationsState()) {
    on<ConversationsEventGetConversationsRequested>(_onGetConversationsRequested);
    on<ConversationsEventCreateConversationRequested>(_onCreateConversationRequested);
    on<ConversationsEventDeleteConversationRequested>(_onDeleteConversationRequested);
    on<ConversationsEventUpdateConversationRequested>(_onUpdateConversationRequested);
  }

  Future<void> _onGetConversationsRequested(
    ConversationsEventGetConversationsRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    if (event.page == 1) {
      emit(state.copyWith(isLoading: true, error: null));
    } else {
      if (state.hasReachedMax) return;
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final result = await getConversationsUseCase(
      GetConversationsParams(page: event.page, size: 20),
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
        final conversations = event.page == 1 
            ? newItems 
            : [...state.conversations, ...newItems];

        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          conversations: conversations,
          hasReachedMax: hasReachedMax,
          currentPage: event.page,
        ));
      },
    );
  }

  Future<void> _onCreateConversationRequested(
    ConversationsEventCreateConversationRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    // Optionally show a loading indicator somewhere, but typically this navigates or updates instantly
    final result = await createConversationUseCase(
      CreateConversationParams(title: event.title),
    );

    result.fold(
      (failure) {
        // Can emit an error state here, maybe a side effect
        emit(state.copyWith(error: failure.message));
      },
      (conversation) {
        // Prepend the new conversation
        emit(state.copyWith(
          conversations: [conversation, ...state.conversations],
          error: null,
        ));
      },
    );
  }

  Future<void> _onDeleteConversationRequested(
    ConversationsEventDeleteConversationRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    final result = await deleteConversationUseCase(
      DeleteConversationParams(id: event.id),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        final updatedConversations = state.conversations
            .where((c) => c.id != event.id)
            .toList();
        emit(state.copyWith(
          conversations: updatedConversations,
          error: null,
        ));
      },
    );
  }

  Future<void> _onUpdateConversationRequested(
    ConversationsEventUpdateConversationRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    final result = await updateConversationUseCase(
      UpdateConversationParams(id: event.id, title: event.title),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message));
      },
      (updatedConversation) {
        final updatedList = state.conversations.map((c) {
          return c.id == event.id ? updatedConversation : c;
        }).toList();
        emit(state.copyWith(
          conversations: updatedList,
          error: null,
        ));
      },
    );
  }
}
