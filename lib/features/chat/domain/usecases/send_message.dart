import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/send_message_result.dart';
import '../repositories/chat_repository.dart';

class SendMessageParams {
  final String conversationId;
  final String content;
  final String providerId;
  final String modelId;

  SendMessageParams({
    required this.conversationId,
    required this.content,
    required this.providerId,
    required this.modelId,
  });
}

class SendMessageUseCase implements UseCase<SendMessageResult, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, SendMessageResult>> call(SendMessageParams params) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
      providerId: params.providerId,
      modelId: params.modelId,
    );
  }
}
