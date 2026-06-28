import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Unified Failure class for Clean Architecture with DDD
/// Keep it simple - use ValidationFailure with custom message for validation errors
@Freezed(genericArgumentFactories: true)
abstract class Failure<T> with _$Failure<T> {
  const Failure._();

  // ===========================================================================
  // VALUE OBJECT FAILURES (Domain Layer)
  // ===========================================================================

  /// For required field validation (empty input)
  const factory Failure.empty([@Default('Field is required') String message]) =
      Empty<T>;

  /// For all validation errors (use custom message)
  const factory Failure.validationFailure([
    @Default('Validation failed') String message,
  ]) = ValidationFailure<T>;

  // ===========================================================================
  // INFRASTRUCTURE FAILURES (Data Layer)
  // ===========================================================================

  const factory Failure.networkFailure([
    @Default('No internet connection') String message,
  ]) = NetworkFailure<T>;

  const factory Failure.serverFailure([
    @Default('Server error') String message,
  ]) = ServerFailure<T>;

  const factory Failure.timeoutFailure([
    @Default('Request timed out') String message,
  ]) = TimeoutFailure<T>;

  const factory Failure.cacheFailure([@Default('Cache error') String message]) =
      CacheFailure<T>;

  const factory Failure.databaseFailure([
    @Default('Database error') String message,
  ]) = DatabaseFailure<T>;
  const factory Failure.methodNotAllowedFailure([
    @Default('Method not allowed') String message,
  ]) = MethodNotAllowedFailure<T>;
  const factory Failure.handshakeFailure([
    @Default('Handshake error') String message,
  ]) = HandshakeFailure<T>;

  // ===========================================================================
  // AUTHORIZATION FAILURES (Application Layer)
  // ===========================================================================

  const factory Failure.unauthorizedFailure([
    @Default('Unauthorized') String message,
  ]) = UnauthorizedFailure<T>;

  const factory Failure.accessDeniedFailure([
    @Default('Access denied') String message,
  ]) = AccessDeniedFailure<T>;

  const factory Failure.authTokenFailure([
    @Default('Authentication failed') String message,
  ]) = AuthTokenFailure<T>;

  const factory Failure.authTokenRefreshFailure([
    @Default('Session expired') String message,
  ]) = AuthTokenRefreshFailure<T>;

  // ===========================================================================
  // HTTP FAILURES (API responses)
  // ===========================================================================

  const factory Failure.badRequestFailure([
    @Default('Bad request') String message,
  ]) = BadRequestFailure<T>;

  const factory Failure.notFoundFailure([
    @Default('Not found') String message,
  ]) = NotFoundFailure<T>;

  const factory Failure.internalServerFailure([
    @Default('Internal server error') String message,
  ]) = InternalServerFailure<T>;

  // ===========================================================================
  // GENERAL FAILURES
  // ===========================================================================

  const factory Failure.formatFailure([
    @Default('Invalid format') String message,
  ]) = FormatFailure<T>;

  const factory Failure.unknownFailure([
    @Default('Unknown error') String message,
  ]) = UnknownFailure<T>;

  const factory Failure.unexpectedFailure({
    @Default('Unexpected error') String message,
    T? data,
  }) = UnexpectedFailure<T>;

  const factory Failure.cancelled([
    @Default('Operation cancelled') String message,
  ]) = CancelledFailure<T>;

  const factory Failure.paymentFailure([
    @Default('Payment failed') String message,
  ]) = PaymentFailure<T>;
}
