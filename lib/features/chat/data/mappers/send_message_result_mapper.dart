import '../../domain/entities/send_message_result.dart';
import '../models/send_message_result_model.dart';
import 'message_mapper.dart';

extension SendMessageResultMapper on SendMessageResultModel {
  SendMessageResult toEntity() {
    return SendMessageResult(
      conversationId: conversationId,
      userMessage: userMessage.toEntity(),
      assistantMessage: assistantMessage.toEntity(),
      reasoning: reasoning,
    );
  }
}

extension SendMessageResultEntityMapper on SendMessageResult {
  SendMessageResultModel toModel() {
    return SendMessageResultModel(
      conversationId: conversationId,
      userMessage: userMessage.toModel(),
      assistantMessage: assistantMessage.toModel(),
      reasoning: reasoning,
    );
  }
}
