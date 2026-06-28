import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class CancelMessageUseCase implements UseCase<void, CancelMessageParams> {
  final ChatRepository repository;

  CancelMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelMessageParams params) {
    return repository.cancelMessage(params.conversationId);
  }
}

class CancelMessageParams {
  final String conversationId;

  CancelMessageParams({required this.conversationId});
}
