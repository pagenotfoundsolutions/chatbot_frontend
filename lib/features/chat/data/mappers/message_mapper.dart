import '../../domain/entities/message.dart';
import '../models/message_model.dart';

extension MessageMapper on MessageModel {
  Message toEntity() {
    return Message(
      id: id,
      role: role,
      content: content,
      thinkingContent: thinkingContent,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension MessageEntityMapper on Message {
  MessageModel toModel() {
    return MessageModel(
      id: id,
      role: role,
      content: content,
      thinkingContent: thinkingContent,
      createdAt: createdAt,
    );
  }
}
