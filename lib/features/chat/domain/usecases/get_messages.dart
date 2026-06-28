import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesParams {
  final String conversationId;
  final int page;
  final int size;

  GetMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.size = 10,
  });
}

class GetMessagesUseCase implements UseCase<PaginatedData<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedData<Message>>> call(GetMessagesParams params) {
    return repository.getMessages(
      params.conversationId,
      page: params.page,
      size: params.size,
    );
  }
}
