import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../network/network_info.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/shared_prefs_storage.dart';
import '../theme/cubit/theme_cubit.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Features - Auth (Deferred Loading via app_router)

  // Features - Chat
  // Features - Profile

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<LocalStorage>(() => SharedPrefsStorageImpl(sl()));

  sl.registerLazySingleton<Dio>(() => DioClient(localStorage: sl()).dio);
  sl.registerLazySingleton<DioClient>(() => DioClient(localStorage: sl()));

  // Google login is temporarily disabled
  // sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));

  sl.registerLazySingleton(() => InternetConnection());

  // State Management
  sl.registerFactory(() => ThemeCubit(sl()));
}
