import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../di/injection.dart';
import '../network/network_info.dart';
import '../network/resp.dart';
import '../utils/app_util.dart';
import 'failure.dart';

// Future<Either<Failure, T>> safeApiCall<T, T2>(
//   Future<c.Response> Function() requestFn, // API request function
//   T Function(dynamic responseBody)? fromJson, // JSON parser
// ) async {
//   try {
//     if (!await sl<NetworkInfo>().isConnected) {
//       return Left(NetworkFailure("No internet connection"));
//     }
//     final response = await requestFn();
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       case 202:
//       case 204:
//         if (fromJson == null) {
//           return Right(response.body);
//         }
//         return Right(fromJson(response.body));
//       case 400:
//         return Left(BadRequestFailure(getErrorMessage(response)));
//       case 401:
//         return Left(UnauthorizedFailure(getErrorMessage(response)));
//       case 403:
//         return Left(AccessDeniedFailure(getErrorMessage(response)));
//       case 404:
//         return Left(NotFoundFailure(getErrorMessage(response)));
//       case 500:
//       case 502:
//       case 503:
//         return Left(ServerFailure(getErrorMessage(response)));

//       default:
//         return Left(ServerFailure(getErrorMessage(response)));
//     }
//   } on SocketException catch (e) {
//     return Left(NetworkFailure(e.message));
//   } on TimeoutException catch (e) {
//     return Left(TimeoutFailure(e.message ?? "Timeout Exception"));
//   } catch (e, stackTrace) {
//     AppUtil.printLog("Error: $e");
//     AppUtil.printLog("Stack Trace: $stackTrace");
//     return Left(ServerFailure("Unexpected error: $e"));
//   }
// }

/// Safe WebSocket call wrapper
/// Handles WebSocket operations and converts exceptions to Either
Future<Either<Failure, Unit>> safeWebSocketCall(
  Future<dynamic> Function() requestFn,
) async {
  try {
    if (!await sl<NetworkInfo>().isConnected) {
      return Left(NetworkFailure("No internet connection"));
    }

    await requestFn();
    return Right(unit);
  } on SocketException catch (e) {
    AppUtil.log("WebSocket SocketException: ${e.message}");
    return Left(NetworkFailure(e.message));
  } on TimeoutException catch (e) {
    AppUtil.log("WebSocket TimeoutException: ${e.message}");
    return Left(TimeoutFailure(e.message ?? "WebSocket timeout"));
  } catch (e, stackTrace) {
    AppUtil.log("WebSocket Error: $e");
    AppUtil.log("Stack Trace: $stackTrace");

    // Parse error message from exception
    String errorMessage = "WebSocket error: $e";
    if (e is Exception) {
      errorMessage = e.toString();
    }

    return Left(ServerFailure(errorMessage));
  }
}

/// Safe WebSocket stream wrapper
/// Similar to safeApiCall - receives raw data, parses in repository
Stream<Either<Failure<String>, T>> safeWebSocketStream<T>(
  Stream<dynamic> stream,
  T Function(dynamic data)? fromJson,
) async* {
  try {
    await for (final rawData in stream) {
      try {
        // Parse data using fromJson if provided (like safeApiCall)
        if (fromJson == null) {
          yield Right(rawData as T);
        } else {
          final parsedData = fromJson(rawData);
          yield Right(parsedData);
        }
      } catch (parseError) {
        // Parsing error - similar to API format error
        AppUtil.log("WebSocket Parse Error: $parseError");
        yield Left(
          FormatFailure("Data parsing error: ${parseError.toString()}"),
        );
      }
    }
  } on SocketException catch (e) {
    AppUtil.log("WebSocket Stream SocketException: ${e.message}");
    yield Left(NetworkFailure(e.message));
  } on TimeoutException catch (e) {
    AppUtil.log("WebSocket Stream TimeoutException: ${e.message}");
    yield Left(TimeoutFailure(e.message ?? "WebSocket stream timeout"));
  } catch (e, stackTrace) {
    AppUtil.log("WebSocket Stream Error: $e");
    AppUtil.log("Stack Trace: $stackTrace");

    // Parse error message from exception
    String errorMessage = "WebSocket stream error: $e";
    if (e is Exception) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    yield Left(ServerFailure(errorMessage));
  }
}

Future<Either<Failure<String>, T>> safeApiCall<T>(
  Future<T> Function() operation,
) async {
  if (!await sl<NetworkInfo>().isConnected) {
    return const Left(NetworkFailure("No internet connection"));
  }

  try {
    final result = await operation();

    return Right(result);
  } on DioException catch (e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Left(TimeoutFailure(e.message ?? "Timeout Exception"));

      case DioExceptionType.badCertificate:
        return Left(ServerFailure(e.message ?? "SSL Handshake Exception"));

      case DioExceptionType.badResponse:
        final response = e.response;

        final statusCode = response?.statusCode ?? 500;

        final responseData = response?.data;

        if (responseData is Map<String, dynamic>) {
          try {
            final errorModel = Resp.fromJson(responseData, (json) => unit);

            switch (statusCode) {
              case 400:
                return Left(BadRequestFailure(errorModel.message));

              case 401:
                return Left(UnauthorizedFailure(errorModel.message));

              case 403:
                return Left(
                  AccessDeniedFailure(errorModel.message.isEmpty ? "Access denied" : errorModel.message),
                );

              case 404:
                return Left(
                  NotFoundFailure(errorModel.message.isEmpty ? "Resource not found" : errorModel.message),
                );

              case 405:
                return Left(MethodNotAllowedFailure(errorModel.message));

              case 422:
                return Left(ValidationFailure(errorModel.message));

              case 500:
              case 502:
              case 503:
              case 504:
                return Left(InternalServerFailure(errorModel.message));

              default:
                return Left(ServerFailure(errorModel.message));
            }
          } on TypeError catch (_) {
            return const Left(
              ServerFailure("Data type mismatch in server response"),
            );
          } on FormatException catch (_) {
            return const Left(ServerFailure("Malformed server response"));
          } catch (_) {
            return const Left(
              ServerFailure("Unexpected error during error handling"),
            );
          }
        } else {
          final dataType = responseData.runtimeType;

          final responseText = responseData?.toString() ?? 'Empty';

          AppUtil.log("Non-Map response received ($dataType): $responseText");

          switch (statusCode) {
            case 400:
              return const Left(BadRequestFailure("Bad request"));

            case 401:
              return const Left(UnauthorizedFailure("Unauthorized access"));

            case 403:
              return const Left(AccessDeniedFailure("Access denied"));

            case 404:
              return const Left(NotFoundFailure("Resource not found"));

            case 405:
              return const Left(MethodNotAllowedFailure("Method not allowed"));

            case 422:
              return const Left(ValidationFailure("Unprocessable entity"));

            case 500:
            case 502:
            case 503:
            case 504:
              return const Left(
                InternalServerFailure(
                  "Server is currently unavailable. Please try again later.",
                ),
              );

            default:
              return Left(
                ServerFailure(
                  "Unexpected response format ($dataType): $responseText",
                ),
              );
          }
        }

      case DioExceptionType.cancel:
        return const Left(ServerFailure("Request was cancelled"));

      case DioExceptionType.connectionError:
        // sl<ConnectivityCubit>().onNoInternet(() async {
        //   return await handleExceptions(operation);
        // });

        return const Left(NetworkFailure("No internet connection"));

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return const Left(NetworkFailure("No internet connection"));
        }

        return Left(UnknownFailure("Unexpected error: ${e.message}"));
    }
  } on SocketException {
    return const Left(NetworkFailure("No internet connection"));
  } on HttpException catch (e) {
    return Left(ServerFailure("HTTP Error: ${e.message}"));
  } on HandshakeException catch (e) {
    return Left(HandshakeFailure(e.message));
  } on TypeError catch (e) {
    return Left(UnknownFailure("Type error: ${e.toString()}"));
  } on FormatException catch (e) {
    return Left(ValidationFailure("Format error: ${e.message}"));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
