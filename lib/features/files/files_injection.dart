import 'package:get_it/get_it.dart';
import 'data/datasources/files_api_client.dart';
import 'data/repositories/files_repository_impl.dart';
import 'domain/repositories/files_repository.dart';
import 'domain/usecases/get_files.dart';
import 'domain/usecases/upload_file.dart';
import 'domain/usecases/delete_file.dart';
import 'presentation/bloc/files_bloc.dart';

void setupFilesInjection() {
  final getIt = GetIt.instance;

  // Data sources
  getIt.registerLazySingleton<FilesApiClient>(
    () => FilesApiClient(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<FilesRepository>(
    () => FilesRepositoryImpl(apiClient: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => UploadFileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFilesUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteFileUseCase(getIt()));

  // Blocs
  getIt.registerLazySingleton(
    () => FilesBloc(
      uploadFileUseCase: getIt(),
      getFilesUseCase: getIt(),
      deleteFileUseCase: getIt(),
    ),
  );
}
