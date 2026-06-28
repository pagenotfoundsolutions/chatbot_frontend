import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class CreateConversationParams {
  final String? title;

  CreateConversationParams({this.title});
}

class CreateConversationUseCase implements UseCase<Conversation, CreateConversationParams> {
  final ChatRepository repository;

  CreateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(CreateConversationParams params) {
    return repository.createConversation(title: params.title);
  }
}
