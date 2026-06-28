import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_message_request.freezed.dart';
part 'send_message_request.g.dart';

@freezed
abstract class SendMessageRequest with _$SendMessageRequest {
  const SendMessageRequest._();
  const factory SendMessageRequest({
    required String content,
    @JsonKey(name: 'provider_id') required String providerId,
    @JsonKey(name: 'model_id') required String modelId,
    @JsonKey(name: 'thinking_enabled') @Default(false) bool thinkingEnabled,
    @JsonKey(name: 'file_id') String? fileId,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);
}
