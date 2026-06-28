import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

extension ProfileMapper on ProfileModel {
  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      profileImageUrl: profileImageUrl,
      dob: dob,
    );
  }
}

extension ProfileEntityMapper on Profile {
  ProfileModel toModel() {
    return ProfileModel(
      id: id,
      name: name,
      profileImageUrl: profileImageUrl,
      dob: dob,
    );
  }
}
