import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../network/network_info.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/shared_prefs_storage.dart';
import '../theme/cubit/theme_cubit.dart';
import '../../features/auth/auth_injection.dart' hide sl;
import '../../features/profile/profile_injection.dart' hide sl;
import '../../features/chat/chat_injection.dart' hide sl;
import '../../features/files/files_injection.dart';
import '../../features/ai_models/ai_models_injection.dart' hide sl;

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Features
  initAuth();
  initProfile();
  initChat();
  setupFilesInjection();
  initAiModels();

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
  sl.registerLazySingleton(() => ThemeCubit(sl()));
}
