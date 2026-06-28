import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/file_entity.dart';

abstract class FilesRepository {
  Future<Either<Failure, FileEntity>> uploadFile(File file);
  Future<Either<Failure, List<FileEntity>>> getFiles();
  Future<Either<Failure, void>> deleteFile(String id);
}
