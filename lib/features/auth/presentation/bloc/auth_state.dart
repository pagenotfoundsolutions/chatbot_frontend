import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(LoadState.idle()) LoadState<User> authStatus,
    @Default(LoadState.idle()) LoadState<void> registerStatus,
    @Default(LoadState.idle()) LoadState<void> verifyOtpStatus,
    @Default(LoadState.idle()) LoadState<void> resendOtpStatus,
    @Default(LoadState.idle()) LoadState<void> passwordResetRequestStatus,
    @Default(LoadState.idle()) LoadState<void> passwordResetStatus,
    String? registeredEmail,
  }) = _AuthState;
}
