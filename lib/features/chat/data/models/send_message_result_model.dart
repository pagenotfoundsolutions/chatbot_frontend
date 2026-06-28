import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_model.dart';

part 'send_message_result_model.freezed.dart';
part 'send_message_result_model.g.dart';

@freezed
abstract class SendMessageResultModel with _$SendMessageResultModel {
  const factory SendMessageResultModel({
    @Default('') @JsonKey(name: 'conversation_id') String conversationId,
    @Default(MessageModel()) @JsonKey(name: 'user_message') MessageModel userMessage,
    @Default(MessageModel()) @JsonKey(name: 'assistant_message') MessageModel assistantMessage,
    String? reasoning,
  }) = _SendMessageResultModel;

  factory SendMessageResultModel.fromJson(Map<String, dynamic> json) => _$SendMessageResultModelFromJson(json);
}
