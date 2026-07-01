import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_role.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required MessageRole role,
    required String content,
    String? thinkingContent,
    String? fileId,
    required DateTime createdAt,
  }) = _Message;
}
