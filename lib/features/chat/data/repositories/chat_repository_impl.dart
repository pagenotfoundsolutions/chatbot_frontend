import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/send_message_result.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_api_service.dart';
import '../mappers/conversation_mapper.dart';
import '../mappers/message_mapper.dart';
import '../mappers/send_message_result_mapper.dart';
import '../models/send_message_request.dart';
import '../datasources/chat_stream_data_source.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/chat_stream_event.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApiService apiService;
  final ChatStreamDataSource streamDataSource;

  ChatRepositoryImpl({required this.apiService, required this.streamDataSource});

  @override
  Future<Either<Failure, PaginatedData<Conversation>>> getConversations({int page = 1, int size = 20}) async {
    return safeApiCall(() async {
      final response = await apiService.getConversations(page: page, size: size);
      if (response.success && response.data != null) {
        final paginatedData = PaginatedData<Conversation>(
          items: response.data!.items.map((e) => e.toEntity()).toList(),
          total: response.data!.total,
          page: response.data!.page,
          size: response.data!.size,
          pages: response.data!.pages,
        );
        return paginatedData;
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({String? title}) async {
    final Map<String, dynamic> body = {};
    if (title != null && title.isNotEmpty) {
      body['title'] = title;
    }
    final result = await safeApiCall(() => apiService.createConversation(request: body));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(String id) async {
    final result = await safeApiCall(() => apiService.getConversation(id));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation(String id, String title) async {
    final result = await safeApiCall(() => apiService.updateConversation(id, {'title': title}));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String id) async {
    final result = await safeApiCall(() => apiService.deleteConversation(id));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success) {
          return const Right(null);
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Future<Either<Failure, PaginatedData<Message>>> getMessages(String conversationId, {int page = 1, int size = 10}) async {
    return safeApiCall(() async {
      final response = await apiService.getMessages(conversationId, page: page, size: size);
      if (response.success && response.data != null) {
        final paginatedData = PaginatedData<Message>(
          items: response.data!.items.map((e) => e.toEntity()).toList(),
          total: response.data!.total,
          page: response.data!.page,
          size: response.data!.size,
          pages: response.data!.pages,
        );
        return paginatedData;
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String conversationId,
    required String content,
    required String providerId,
    required String modelId,
    String? fileId,
  }) async {
    final request = SendMessageRequest(
      content: content,
      providerId: providerId,
      modelId: modelId,
      fileId: fileId,
    );
    final result = await safeApiCall(() => apiService.sendMessage(conversationId, request));
    return result.fold(
      (failure) => Left(failure),
      (response) {
        if (response.success && response.data != null) {
          return Right(response.data!.toEntity());
        }
        return Left(ServerFailure(response.message));
      },
    );
  }

  @override
  Stream<Either<Failure, ChatStreamEvent>> streamMessage({
    required String conversationId,
    required String content,
    required String providerId,
    required String modelId,
    bool thinkingEnabled = false,
    String? fileId,
    CancelToken? cancelToken,
  }) async* {
    try {
      final request = SendMessageRequest(
        content: content,
        providerId: providerId,
        modelId: modelId,
        thinkingEnabled: thinkingEnabled,
        fileId: fileId,
      );

      final stream = streamDataSource.streamMessage(conversationId, request, cancelToken: cancelToken);

      await for (final event in stream) {
        yield Right(event);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // Ignored, user cancelled the request
        return;
      }
      yield Left(ServerFailure(e.toString()));
    } catch (e) {
      // The data source already throws mapped exceptions if needed, or we map it here
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMessage(String conversationId) async {
    final result = await safeApiCall(() => apiService.cancelMessage(conversationId));
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
