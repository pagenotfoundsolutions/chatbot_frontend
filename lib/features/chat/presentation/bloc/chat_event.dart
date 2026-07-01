import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.opened(String conversationId) = ChatEventOpened;
  const factory ChatEvent.reset() = ChatEventReset;
  const factory ChatEvent.loadMessagesRequested({@Default(1) int page}) = ChatEventLoadMessagesRequested;
  const factory ChatEvent.sendMessageRequested({
    required String content,
    required String providerId,
    required String modelId,
    @Default(false) bool thinkingEnabled,
    String? fileId,
  }) = ChatEventSendMessageRequested;
  
  const factory ChatEvent.streamChunkReceived(String chunk) = ChatEventStreamChunkReceived;
  const factory ChatEvent.streamCompleted(String conversationId) = ChatEventStreamCompleted;
  const factory ChatEvent.streamError(String error) = ChatEventStreamError;
  const factory ChatEvent.cancelGenerationRequested() = ChatEventCancelGenerationRequested;
}
