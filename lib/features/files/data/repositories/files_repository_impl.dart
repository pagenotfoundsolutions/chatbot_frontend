import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/files_api_client.dart';
import '../mappers/file_mapper.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesApiClient apiClient;

  FilesRepositoryImpl({required this.apiClient});

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
  Future<Either<Failure, List<FileEntity>>> getFiles() async {
    return safeApiCall(() async {
      final response = await apiClient.getFiles();
      if (response.success && response.data != null) {
        return FileMapper.toEntityList(response.data!);
      } else {
        throw Exception(response.message);
      }
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
