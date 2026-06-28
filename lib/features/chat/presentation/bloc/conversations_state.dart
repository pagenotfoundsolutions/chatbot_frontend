import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation.dart';

part 'conversations_state.freezed.dart';

@freezed
abstract class ConversationsState with _$ConversationsState {
  const factory ConversationsState({
    @Default([]) List<Conversation> conversations,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedMax,
    @Default(1) int currentPage,
    String? error,
  }) = _ConversationsState;
}
