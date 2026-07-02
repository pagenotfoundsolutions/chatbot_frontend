import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/paginated_data.dart';
import '../entities/file_entity.dart';

abstract class FilesRepository {
  Future<Either<Failure, FileEntity>> uploadFile(String fileName, List<int> bytes);
  Future<Either<Failure, PaginatedData<FileEntity>>> getFiles(int page, int size);
  Future<Either<Failure, FileEntity>> getFileDetail(String id);
  Future<Either<Failure, List<int>>> downloadFile(String filePath);
  Future<Either<Failure, void>> deleteFile(String id);
}
