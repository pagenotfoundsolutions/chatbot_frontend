import 'package:dartz/dartz.dart';
import '../error/failure.dart';

/// Base class for all use cases following Command/Query pattern
/// [Type] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't need any parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Represents no parameters for use cases that don't need input
class NoParams {
  const NoParams();
}
