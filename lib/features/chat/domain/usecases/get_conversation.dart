import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationParams {
  final String id;

  GetConversationParams({required this.id});
}

class GetConversationUseCase implements UseCase<Conversation, GetConversationParams> {
  final ChatRepository repository;

  GetConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(GetConversationParams params) {
    return repository.getConversation(params.id);
  }
}
