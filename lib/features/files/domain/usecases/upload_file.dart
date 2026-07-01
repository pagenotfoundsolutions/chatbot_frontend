import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/file_entity.dart';
import '../repositories/files_repository.dart';

class UploadFileParams {
  final String fileName;
  final List<int> bytes;

  UploadFileParams({required this.fileName, required this.bytes});
}

class UploadFileUseCase implements UseCase<FileEntity, UploadFileParams> {
  final FilesRepository repository;

  UploadFileUseCase(this.repository);

  @override
  Future<Either<Failure, FileEntity>> call(UploadFileParams params) {
    return repository.uploadFile(params.fileName, params.bytes);
  }
}
