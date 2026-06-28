import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class UpdateConversationParams {
  final String id;
  final String title;

  UpdateConversationParams({required this.id, required this.title});
}

class UpdateConversationUseCase implements UseCase<Conversation, UpdateConversationParams> {
  final ChatRepository repository;

  UpdateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(UpdateConversationParams params) {
    return repository.updateConversation(params.id, params.title);
  }
}
