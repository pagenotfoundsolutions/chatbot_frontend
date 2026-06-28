import '../../domain/entities/conversation.dart';
import '../models/conversation_model.dart';

extension ConversationMapper on ConversationModel {
  Conversation toEntity() {
    return Conversation(
      id: id,
      title: title,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

extension ConversationEntityMapper on Conversation {
  ConversationModel toModel() {
    return ConversationModel(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
