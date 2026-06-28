import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import '../storage/local_storage.dart';

class DioClient {
  final Dio _dio;

  DioClient({required LocalStorage localStorage})
      : _dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiUrl,
            connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Add Interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(localStorage, _dio),
      RetryInterceptor(
        dio: _dio,
        maxRetries: 3,
      ),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}
