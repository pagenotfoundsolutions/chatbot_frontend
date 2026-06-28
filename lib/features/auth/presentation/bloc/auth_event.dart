import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested(String email, String password) = LoginRequested;
  const factory AuthEvent.registerRequested(String email, String password) = RegisterRequested;
  const factory AuthEvent.verifyOtpRequested(String email, String otp) = VerifyOtpRequested;
  const factory AuthEvent.resendOtpRequested(String email) = ResendOtpRequested;
  const factory AuthEvent.forgotPasswordRequested(String email) = ForgotPasswordRequested;
  const factory AuthEvent.resetPasswordRequested(String email, String otp, String newPassword) = ResetPasswordRequested;
  const factory AuthEvent.googleSignInRequested() = GoogleSignInRequested;
  const factory AuthEvent.logoutRequested() = LogoutRequested;
}
