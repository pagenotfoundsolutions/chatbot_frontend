import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_entity.dart';
import '../repositories/files_repository.dart';

class GetFilesUseCase implements UseCase<List<FileEntity>, NoParams> {
  final FilesRepository repository;

  GetFilesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FileEntity>>> call(NoParams params) {
    return repository.getFiles();
  }
}
