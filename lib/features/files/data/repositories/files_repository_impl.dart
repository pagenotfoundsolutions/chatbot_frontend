import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/domain/entities/paginated_data.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/files_api_client.dart';
import '../mappers/file_mapper.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesApiClient apiClient;
  final Dio dio;

  FilesRepositoryImpl({required this.apiClient, required this.dio});

  @override
  Future<Either<Failure, FileEntity>> uploadFile(String fileName, List<int> bytes) async {
    return safeApiCall(() async {
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      final response = await apiClient.uploadFile(multipartFile);
      if (response.success && response.data != null) {
        return FileMapper.toEntity(response.data!);
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, PaginatedData<FileEntity>>> getFiles(int page, int size) async {
    return safeApiCall(() async {
      final response = await apiClient.getFiles(page: page, size: size);
      if (response.success && response.data != null) {
        final data = response.data!;
        return PaginatedData<FileEntity>(
          items: FileMapper.toEntityList(data.items),
          total: data.total,
          page: data.page,
          size: data.size,
          pages: data.pages,
        );
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, FileEntity>> getFileDetail(String id) async {
    return safeApiCall(() async {
      final response = await apiClient.getFileDetail(id);
      if (response.success && response.data != null) {
        return FileMapper.toEntity(response.data!);
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, List<int>>> downloadFile(String filePath) async {
    return safeApiCall(() async {
      final response = await dio.get<List<int>>(
        '/files/$filePath',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('File is empty or could not be downloaded');
      }
      return data;
    });
  }

  @override
  Future<Either<Failure, void>> deleteFile(String id) async {
    return safeApiCall(() async {
      final response = await apiClient.deleteFile(id);
      if (!response.success) {
        throw Exception(response.message);
      }
    });
  }
}
