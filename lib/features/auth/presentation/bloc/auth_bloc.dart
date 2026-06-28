import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final LogoutUseCase logoutUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.googleSignInUseCase,
    required this.logoutUseCase,
    required this.requestPasswordResetUseCase,
    required this.resetPasswordUseCase,
  }) : super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(authStatus: const LoadState.loading()));
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(state.copyWith(authStatus: LoadState.error(failure.message))),
      (user) => emit(state.copyWith(authStatus: LoadState.success('Login successful', user))),
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(registerStatus: const LoadState.loading()));
    final result = await registerUseCase(RegisterParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(state.copyWith(registerStatus: LoadState.error(failure.message))),
      (_) => emit(state.copyWith(
        registerStatus: const LoadState.success('Registration successful! Please verify OTP.'),
        registeredEmail: event.email,
      )),
    );
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(verifyOtpStatus: const LoadState.loading()));
    final result = await verifyOtpUseCase(VerifyOtpParams(email: event.email, otp: event.otp));
    result.fold(
      (failure) => emit(state.copyWith(verifyOtpStatus: LoadState.error(failure.message))),
      (_) => emit(state.copyWith(
        verifyOtpStatus: const LoadState.success('OTP Verified. Please log in.'),
      )),
    );
  }

  Future<void> _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(resendOtpStatus: const LoadState.loading()));
    final result = await resendOtpUseCase(event.email);
    result.fold(
      (failure) => emit(state.copyWith(resendOtpStatus: LoadState.error(failure.message))),
      (_) => emit(state.copyWith(resendOtpStatus: const LoadState.success('OTP Resent successfully.'))),
    );
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(authStatus: const LoadState.loading()));
    final result = await googleSignInUseCase();
    result.fold(
      (failure) => emit(state.copyWith(authStatus: LoadState.error(failure.message))),
      (user) => emit(state.copyWith(authStatus: LoadState.success('Login successful', user))),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    // Reset to initial state
    emit(const AuthState());
    await logoutUseCase();
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(passwordResetRequestStatus: const LoadState.loading()));
    final result = await requestPasswordResetUseCase(event.email);
    result.fold(
      (failure) => emit(state.copyWith(passwordResetRequestStatus: LoadState.error(failure.message))),
      (_) => emit(state.copyWith(passwordResetRequestStatus: const LoadState.success('OTP sent to your email.'))),
    );
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(passwordResetStatus: const LoadState.loading()));
    final result = await resetPasswordUseCase(
      ResetPasswordParams(email: event.email, otp: event.otp, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(state.copyWith(passwordResetStatus: LoadState.error(failure.message))),
      (_) => emit(state.copyWith(passwordResetStatus: const LoadState.success('Password reset successfully! Please login.'))),
    );
  }
}
