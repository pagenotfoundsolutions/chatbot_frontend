import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/entities/file_entity.dart';

part 'files_state.freezed.dart';

@freezed
abstract class FilesState with _$FilesState {
  const factory FilesState({
    @Default(LoadState.idle()) LoadState<FileEntity> uploadStatus,
    @Default(LoadState.idle()) LoadState<List<FileEntity>> filesStatus,
    @Default(LoadState.idle()) LoadState<void> deleteStatus,
  }) = _FilesState;
}
