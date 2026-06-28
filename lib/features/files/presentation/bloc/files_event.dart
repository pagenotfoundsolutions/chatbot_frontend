import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_event.freezed.dart';

@freezed
abstract class FilesEvent with _$FilesEvent {
  const factory FilesEvent.uploadFile(File file) = UploadFileEvent;
  const factory FilesEvent.fetchFiles() = FetchFilesEvent;
}
