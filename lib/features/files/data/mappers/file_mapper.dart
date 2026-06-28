import '../../domain/entities/file_entity.dart';
import '../../domain/entities/file_status.dart';
import '../models/file_model.dart';

class FileMapper {
  static FileEntity toEntity(FileModel model) {
    return FileEntity(
      id: model.id,
      originalFilename: model.originalFilename,
      mimeType: model.mimeType,
      sizeBytes: model.sizeBytes,
      status: FileStatus.fromString(model.status),
      errorMessage: model.errorMessage,
      createdAt: model.createdAt,
      filePath: model.filePath,
    );
  }

  static List<FileEntity> toEntityList(List<FileModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }
}
