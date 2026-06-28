import 'dart:async';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../constants/api_constants.dart';
import '../../config/env_config.dart';
import '../../storage/local_storage.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;
  final Dio _dio; // The main Dio instance for retrying requests
  
  // A separate Dio instance specifically for token refreshing to avoid infinite loops
  late final Dio _refreshDio; 

  bool _isRefreshing = false;
  Completer<bool>? _refreshTokenCompleter;

  AuthInterceptor(this._localStorage, this._dio) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      ),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localStorage.getString(AppConstants.accessTokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the error is 401 Unauthorized, attempt to refresh the token
    if (err.response?.statusCode == 401) {
      final refreshToken = _localStorage.getString(AppConstants.refreshTokenKey);
      
      // If no refresh token exists, we can't refresh. Log out and reject.
      if (refreshToken == null || refreshToken.isEmpty) {
        await _performLogout();
        return handler.next(err);
      }

      // If a refresh is already in progress, wait for it to complete
      if (_isRefreshing) {
        final success = await _refreshTokenCompleter?.future ?? false;
        if (success) {
          return _retryOriginalRequest(err.requestOptions, handler);
        } else {
          return handler.next(err);
        }
      }

      // Start the token refresh process
      _isRefreshing = true;
      _refreshTokenCompleter = Completer<bool>();

      try {
        // Hit the refresh endpoint using the clean Dio instance
        final response = await _refreshDio.post(
          ApiConstants.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token']; // Optional based on backend

          if (newAccessToken != null) {
            await _localStorage.saveString(AppConstants.accessTokenKey, newAccessToken);
            if (newRefreshToken != null) {
              await _localStorage.saveString(AppConstants.refreshTokenKey, newRefreshToken);
            }

            _isRefreshing = false;
            _refreshTokenCompleter?.complete(true);
            return _retryOriginalRequest(err.requestOptions, handler);
          }
        }
        
        // If refresh fails for some reason (e.g., malformed response)
        throw Exception('Refresh failed');
      } catch (e) {
        // Token refresh failed completely (e.g., refresh token expired)
        _isRefreshing = false;
        _refreshTokenCompleter?.complete(false);
        await _performLogout();
        return handler.next(err);
      }
    }

    // Not a 401 error, just pass it along
    super.onError(err, handler);
  }

  Future<void> _retryOriginalRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Re-fetch the newly saved access token
      final newToken = _localStorage.getString(AppConstants.accessTokenKey);
      
      // Clone the original request and inject the new token
      final options = Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $newToken',
        },
      );

      final response = await _dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );

      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _performLogout() async {
    // Clear all storage on unauthorized terminal failure
    await _localStorage.clear();
    // TODO: Dispatch a global logout event (e.g. via Stream or NavigationKey) 
    // to kick the user to the Login screen.
  }
}
