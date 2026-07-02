import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/files_repository.dart';

class DownloadFileUseCase implements UseCase<List<int>, String> {
  final FilesRepository repository;

  DownloadFileUseCase(this.repository);

  /// [filePath] is the file's `storage_path`, e.g. `userId/uuid.pdf`.
  @override
  Future<Either<Failure, List<int>>> call(String filePath) {
    return repository.downloadFile(filePath);
  }
}
