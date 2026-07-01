import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/file_entity.dart';

abstract class FilesRepository {
  Future<Either<Failure, FileEntity>> uploadFile(String fileName, List<int> bytes);
  Future<Either<Failure, List<FileEntity>>> getFiles();
  Future<Either<Failure, void>> deleteFile(String id);
}
