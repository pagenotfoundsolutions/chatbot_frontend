import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsParams {
  final int page;
  final int size;

  GetConversationsParams({this.page = 1, this.size = 10});
}

class GetConversationsUseCase implements UseCase<PaginatedData<Conversation>, GetConversationsParams> {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedData<Conversation>>> call(GetConversationsParams params) {
    return repository.getConversations(page: params.page, size: params.size);
  }
}
