import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteConversationParams {
  final String id;

  DeleteConversationParams({required this.id});
}

class DeleteConversationUseCase implements UseCase<void, DeleteConversationParams> {
  final ChatRepository repository;

  DeleteConversationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) {
    return repository.deleteConversation(params.id);
  }
}
