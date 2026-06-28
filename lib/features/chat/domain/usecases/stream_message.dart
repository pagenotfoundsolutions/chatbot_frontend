import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_stream_event.dart';
import '../repositories/chat_repository.dart';

class StreamMessageUseCase {
  final ChatRepository repository;

  StreamMessageUseCase(this.repository);

  Stream<Either<Failure, ChatStreamEvent>> call(StreamMessageParams params) {
    return repository.streamMessage(
      conversationId: params.conversationId,
      content: params.content,
      providerId: params.providerId,
      modelId: params.modelId,
      thinkingEnabled: params.thinkingEnabled,
      cancelToken: params.cancelToken,
    );
  }
}

class StreamMessageParams {
  final String conversationId;
  final String content;
  final String providerId;
  final String modelId;
  final bool thinkingEnabled;
  final CancelToken? cancelToken;

  StreamMessageParams({
    required this.conversationId,
    required this.content,
    required this.providerId,
    required this.modelId,
    this.thinkingEnabled = false,
    this.cancelToken,
  });
}
