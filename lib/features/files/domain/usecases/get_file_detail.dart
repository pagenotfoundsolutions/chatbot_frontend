import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_entity.dart';
import '../repositories/files_repository.dart';

class GetFileDetailUseCase implements UseCase<FileEntity, String> {
  final FilesRepository repository;

  GetFileDetailUseCase(this.repository);

  @override
  Future<Either<Failure, FileEntity>> call(String fileId) {
    return repository.getFileDetail(fileId);
  }
}
