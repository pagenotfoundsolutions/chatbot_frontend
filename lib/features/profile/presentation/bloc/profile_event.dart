import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.freezed.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.getProfileRequested() = GetProfileRequested;
  
  const factory ProfileEvent.createProfileRequested({
    required String name,
    String? profileImageUrl,
    String? dob,
  }) = CreateProfileRequested;

  const factory ProfileEvent.updateProfileRequested({
    required String name,
    String? profileImageUrl,
    String? dob,
  }) = UpdateProfileRequested;
}
