import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/files_repository.dart';

class DeleteFileUseCase {
  final FilesRepository repository;

  DeleteFileUseCase(this.repository);

  Future<Either<Failure, void>> call(String fileId) async {
    return await repository.deleteFile(fileId);
  }
}
