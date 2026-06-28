import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_request.freezed.dart';
part 'create_profile_request.g.dart';

@freezed
abstract class CreateProfileRequest with _$CreateProfileRequest {
  const CreateProfileRequest._();
  const factory CreateProfileRequest({
    required String name,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    String? dob,
  }) = _CreateProfileRequest;

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileRequestFromJson(json);
}
