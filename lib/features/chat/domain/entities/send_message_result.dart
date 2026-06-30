import 'package:freezed_annotation/freezed_annotation.dart';
import 'message.dart';

part 'send_message_result.freezed.dart';

@freezed
abstract class SendMessageResult with _$SendMessageResult {
  const factory SendMessageResult({
    required String conversationId,
    required Message userMessage,
    required Message assistantMessage,
  }) = _SendMessageResult;
}
