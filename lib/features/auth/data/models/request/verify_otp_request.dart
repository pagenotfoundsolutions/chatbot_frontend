import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_request.freezed.dart';
part 'verify_otp_request.g.dart';

@freezed
abstract class VerifyOtpRequest with _$VerifyOtpRequest {
  const VerifyOtpRequest._();
  const factory VerifyOtpRequest({
    required String email,
    @JsonKey(name: 'otp_code') required String otpCode,
  }) = _VerifyOtpRequest;

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);
}
