import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/domain/entities/paginated_data.dart';
import '../entities/file_entity.dart';
import '../repositories/files_repository.dart';

class GetFilesParams {
  final int page;
  final int size;

  GetFilesParams({this.page = 1, this.size = 20});
}

class GetFilesUseCase implements UseCase<PaginatedData<FileEntity>, GetFilesParams> {
  final FilesRepository repository;

  GetFilesUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedData<FileEntity>>> call(GetFilesParams params) {
    return repository.getFiles(params.page, params.size);
  }
}
