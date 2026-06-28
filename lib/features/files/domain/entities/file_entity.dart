import 'file_status.dart';

class FileEntity {
  final String id;
  final String originalFilename;
  final String mimeType;
  final int sizeBytes;
  final FileStatus status;
  final String? errorMessage;
  final DateTime? createdAt;
  final String filePath;

  FileEntity({
    required this.id,
    required this.originalFilename,
    required this.mimeType,
    required this.sizeBytes,
    required this.status,
    this.errorMessage,
    this.createdAt,
    required this.filePath,
  });
}
