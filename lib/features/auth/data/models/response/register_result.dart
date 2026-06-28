import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_result.freezed.dart';
part 'register_result.g.dart';

@freezed
abstract class RegisterResult with _$RegisterResult {
  const factory RegisterResult({
    @Default('') String id,
    @Default('') String email,
    @JsonKey(name: 'otp_code') String? otpCode,
  }) = _RegisterResult;

  factory RegisterResult.fromJson(Map<String, dynamic> json) =>
      _$RegisterResultFromJson(json);
}
