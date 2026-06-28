import 'package:dartz/dartz.dart';
import '../error/failure.dart';

/// Base class for all use cases following Command/Query pattern
/// [TType] is the return type
/// [Params] is the input parameters type
abstract class UseCase<TType, Params> {
  Future<Either<Failure, TType>> call(Params params);
}

/// Use case that doesn't need any parameters
abstract class UseCaseNoParams<TType> {
  Future<Either<Failure, TType>> call();
}

/// Represents no parameters for use cases that don't need input
class NoParams {
  const NoParams();
}
