import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/message.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    String? conversationId,
    @Default([]) List<Message> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isSending,
    @Default(false) bool hasReachedMax,
    @Default(1) int currentPage,
    String? error,
  }) = _ChatState;
}
