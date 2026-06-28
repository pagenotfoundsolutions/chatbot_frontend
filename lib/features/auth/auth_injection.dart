import 'package:get_it/get_it.dart';

import 'package:dio/dio.dart';
import 'data/datasources/auth_api_client.dart';
import 'data/datasources/google_auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/google_sign_in_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/verify_otp_usecase.dart';
import 'domain/usecases/resend_otp_usecase.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/request_password_reset_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void initAuth() {
  if (!sl.isRegistered<AuthBloc>()) {
    // Bloc
    sl.registerLazySingleton(() => AuthBloc(
          loginUseCase: sl(),
          registerUseCase: sl(),
          verifyOtpUseCase: sl(),
          googleSignInUseCase: sl(),
          logoutUseCase: sl(),
          checkAuthStatusUseCase: sl(),
          requestPasswordResetUseCase: sl(),
          resetPasswordUseCase: sl(),
          resendOtpUseCase: sl(),
        ));

    // Use cases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
    sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
    sl.registerLazySingleton(() => ResendOtpUseCase(sl()));
    sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
    sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
    sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

    // Repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        apiClient: sl(),
        googleAuthRemoteDataSource: sl(),
        localStorage: sl(),
      ),
    );

    // Data sources
    sl.registerLazySingleton(() => AuthApiClient(sl<Dio>()));
    sl.registerLazySingleton<GoogleAuthRemoteDataSource>(
      () => GoogleAuthRemoteDataSourceImpl(),
    );
  }
}
