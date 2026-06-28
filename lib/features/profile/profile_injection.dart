import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/profile_api_client.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/create_profile_usecase.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'domain/usecases/update_profile_usecase.dart';
import 'presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void initProfile() {
  if (!sl.isRegistered<ProfileApiClient>()) {
    // Data sources
    sl.registerLazySingleton<ProfileApiClient>(
        () => ProfileApiClient(sl<Dio>()));

    // Repository
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetProfileUseCase(sl()));
    sl.registerLazySingleton(() => CreateProfileUseCase(sl()));
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

    // Bloc
    sl.registerLazySingleton(
      () => ProfileBloc(
        getProfileUseCase: sl(),
        createProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ),
    );
  }
}
