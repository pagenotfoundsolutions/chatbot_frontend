import 'dart:async';
import 'package:dio/dio.dart';

/// Custom interceptor to retry failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
  }) : _dio = dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    int retries = err.requestOptions.extra['retries'] ?? 0;

    // Retry only on network timeouts, or specific 5xx server errors
    if (_shouldRetry(err) && retries < maxRetries) {
      retries++;
      
      // Exponential backoff: 1s, 2s, 4s...
      final delay = Duration(seconds: 1 << (retries - 1));
      
      try {
        await Future.delayed(delay);

        // Update retry count in extra data
        final options = err.requestOptions;
        options.extra['retries'] = retries;

        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on standard transient server errors (500, 502, 503, 504)
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode <= 504) {
        return true;
      }
    }

    return false;
  }
}
