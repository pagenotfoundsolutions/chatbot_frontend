import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/entities/profile.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(LoadState.idle()) LoadState<Profile> profileStatus,
    @Default(LoadState.idle()) LoadState<Profile> createStatus,
    @Default(LoadState.idle()) LoadState<Profile> updateStatus,
  }) = _ProfileState;
}
