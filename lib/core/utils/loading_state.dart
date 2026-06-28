import 'package:freezed_annotation/freezed_annotation.dart';

part 'loading_state.freezed.dart';

typedef LoadingState = LoadState<void>;

@freezed
sealed class LoadState<T> with _$LoadState<T> {
  const LoadState._();

  const factory LoadState.idle([T? data]) = Idle<T>;

  const factory LoadState.loading([T? data]) = Loading<T>;

  const factory LoadState.error([@Default('') String message, T? data]) =
      Error<T>;

  const factory LoadState.success([@Default('') String message, T? data]) =
      Success<T>;
  const factory LoadState.loaded(T data) = Loaded<T>;

  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is Success<T> || this is Loaded<T>;
  bool get isLoaded => this is Loaded<T> || this is Success<T>;
  bool get isError => this is Error<T>;
  bool get isIdle => this is Idle<T>;

  String get message => maybeWhen(
    error: (msg, data) => msg,
    success: (msg, data) => msg,
    orElse: () => '',
  );
  @override
  T? get data => when(
    error: (msg, data) => data,
    success: (msg, data) => data,
    idle: (data) => data,
    loading: (data) => data,
    loaded: (data) => data,
  );
  bool get hasData => data != null;
}
