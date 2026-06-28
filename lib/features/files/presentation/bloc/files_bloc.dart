import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/usecases/get_files.dart';
import '../../domain/usecases/upload_file.dart';
import 'files_event.dart';
import 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final UploadFileUseCase uploadFileUseCase;
  final GetFilesUseCase getFilesUseCase;

  FilesBloc({
    required this.uploadFileUseCase,
    required this.getFilesUseCase,
  }) : super(const FilesState()) {
    on<UploadFileEvent>(_onUploadFile);
    on<FetchFilesEvent>(_onFetchFiles);
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<FilesState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: const LoadState.loading()));

    final result = await uploadFileUseCase(UploadFileParams(file: event.file));

    result.fold(
      (failure) => emit(
        state.copyWith(uploadStatus: LoadState.error(failure.message)),
      ),
      (fileEntity) {
        emit(state.copyWith(uploadStatus: LoadState.loaded(fileEntity)));
        // Refresh the file list after successful upload
        add(const FilesEvent.fetchFiles());
      },
    );
  }

  Future<void> _onFetchFiles(
    FetchFilesEvent event,
    Emitter<FilesState> emit,
  ) async {
    emit(state.copyWith(filesStatus: const LoadState.loading()));

    final result = await getFilesUseCase(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(filesStatus: LoadState.error(failure.message)),
      ),
      (files) => emit(state.copyWith(filesStatus: LoadState.loaded(files))),
    );
  }
}
