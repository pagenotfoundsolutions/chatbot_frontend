import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/usecases/get_files.dart';
import '../../domain/usecases/upload_file.dart';
import '../../domain/usecases/delete_file.dart';
import 'files_event.dart';
import 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final UploadFileUseCase uploadFileUseCase;
  final GetFilesUseCase getFilesUseCase;
  final DeleteFileUseCase deleteFileUseCase;

  static const int _pageSize = 20;

  FilesBloc({
    required this.uploadFileUseCase,
    required this.getFilesUseCase,
    required this.deleteFileUseCase,
  }) : super(const FilesState()) {
    on<UploadFileEvent>(_onUploadFile);
    on<FetchFilesEvent>(_onFetchFiles);
    on<LoadMoreFilesEvent>(_onLoadMoreFiles);
    on<DeleteFileEvent>(_onDeleteFile);
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<FilesState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: const LoadState.loading()));

    final result = await uploadFileUseCase(UploadFileParams(fileName: event.fileName, bytes: event.bytes));

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

    final result = await getFilesUseCase(GetFilesParams(page: 1, size: _pageSize));

    result.fold(
      (failure) => emit(
        state.copyWith(filesStatus: LoadState.error(failure.message)),
      ),
      (page) => emit(
        state.copyWith(
          filesStatus: LoadState.loaded(page.items),
          files: page.items,
          currentPage: page.page,
          totalPages: page.pages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreFiles(
    LoadMoreFilesEvent event,
    Emitter<FilesState> emit,
  ) async {
    // Nothing more to load, or a load is already in flight.
    if (state.isLoadingMore || state.currentPage >= state.totalPages) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await getFilesUseCase(GetFilesParams(page: nextPage, size: _pageSize));

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(
        state.copyWith(
          files: [...state.files, ...page.items],
          filesStatus: LoadState.loaded([...state.files, ...page.items]),
          currentPage: page.page,
          totalPages: page.pages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onDeleteFile(
    DeleteFileEvent event,
    Emitter<FilesState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: const LoadState.loading()));

    final result = await deleteFileUseCase(event.fileId);

    result.fold(
      (failure) => emit(
        state.copyWith(deleteStatus: LoadState.error(failure.message)),
      ),
      (_) {
        emit(state.copyWith(deleteStatus: const LoadState.loaded(null)));
        add(const FilesEvent.fetchFiles());
      },
    );
  }
}
