import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/paginated_data.dart';
import 'package:dartz/dartz.dart';

import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/send_message_result.dart';
import '../entities/chat_stream_event.dart';

abstract class ChatRepository {
  Future<Either<Failure, PaginatedData<Conversation>>> getConversations({int page = 1, int size = 20});
  
  Future<Either<Failure, Conversation>> createConversation({String? title});
  
  Future<Either<Failure, Conversation>> getConversation(String id);
  
  Future<Either<Failure, Conversation>> updateConversation(String id, String title);
  
  Future<Either<Failure, void>> deleteConversation(String id);
  
  Future<Either<Failure, PaginatedData<Message>>> getMessages(String conversationId, {int page = 1, int size = 10});
  
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String conversationId,
    required String content,
    required String providerId,
    required String modelId,
    String? fileId,
  });

  Stream<Either<Failure, ChatStreamEvent>> streamMessage({
    required String conversationId,
    required String content,
    required String providerId,
    required String modelId,
    bool thinkingEnabled = false,
    String? fileId,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, void>> cancelMessage(String conversationId);
}
