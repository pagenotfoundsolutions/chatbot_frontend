import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversations_event.freezed.dart';

@freezed
class ConversationsEvent with _$ConversationsEvent {
  const factory ConversationsEvent.getConversationsRequested({@Default(1) int page}) = ConversationsEventGetConversationsRequested;
  const factory ConversationsEvent.createConversationRequested({String? title}) = ConversationsEventCreateConversationRequested;
  const factory ConversationsEvent.deleteConversationRequested(String id) = ConversationsEventDeleteConversationRequested;
  const factory ConversationsEvent.updateConversationRequested(String id, String title) = ConversationsEventUpdateConversationRequested;
}
