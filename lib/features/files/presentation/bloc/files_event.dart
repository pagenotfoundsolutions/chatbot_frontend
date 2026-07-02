import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_event.freezed.dart';

@freezed
abstract class FilesEvent with _$FilesEvent {
  const factory FilesEvent.uploadFile(String fileName, List<int> bytes) = UploadFileEvent;
  const factory FilesEvent.fetchFiles() = FetchFilesEvent;
  const factory FilesEvent.loadMoreFiles() = LoadMoreFilesEvent;
  const factory FilesEvent.deleteFile(String fileId) = DeleteFileEvent;
}
