import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/loading_state.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.createProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileState()) {
    on<GetProfileRequested>(_onGetProfileRequested);
    on<CreateProfileRequested>(_onCreateProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ResetProfileRequested>(_onResetProfileRequested);
  }

  void _onResetProfileRequested(ResetProfileRequested event, Emitter<ProfileState> emit) {
    emit(const ProfileState());
  }

  Future<void> _onGetProfileRequested(GetProfileRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(profileStatus: LoadState.loading(state.profileStatus.data)));
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(state.copyWith(profileStatus: LoadState.error(failure.message))),
      (profile) => emit(state.copyWith(profileStatus: LoadState.success('Profile loaded', profile))),
    );
  }

  Future<void> _onCreateProfileRequested(CreateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(createStatus: const LoadState.loading()));
    final result = await createProfileUseCase(
      CreateProfileParams(
        name: event.name,
        profileImageUrl: event.profileImageUrl,
        dob: event.dob,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(createStatus: LoadState.error(failure.message))),
      (profile) => emit(state.copyWith(
        createStatus: LoadState.success('Profile created successfully', profile),
        profileStatus: LoadState.success('Profile loaded', profile),
      )),
    );
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(updateStatus: const LoadState.loading()));
    final result = await updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        profileImageUrl: event.profileImageUrl,
        dob: event.dob,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(updateStatus: LoadState.error(failure.message))),
      (profile) => emit(state.copyWith(
        updateStatus: LoadState.success('Profile updated successfully', profile),
        profileStatus: LoadState.success('Profile loaded', profile),
      )),
    );
  }
}
