import 'package:flutter/material.dart';
import '../../../../core/widgets/app_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/auth_event.dart';
import '../../presentation/bloc/auth_state.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = context.read<AuthBloc>();
      final profileBloc = context.read<ProfileBloc>();
      
      // First, check if the user is authenticated (loads token from storage)
      if (authBloc.state.authStatus.isIdle) {
        authBloc.add(const AuthEvent.checkAuthStatus());
      } else if (authBloc.state.authStatus.isSuccess && profileBloc.state.profileStatus.isIdle) {
        // If they are already authenticated but profile hasn't loaded (e.g. hot reload)
        profileBloc.add(const ProfileEvent.getProfileRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => 
          previous.authStatus != current.authStatus && 
          current.authStatus.isSuccess,
      listener: (context, state) {
        final profileBloc = context.read<ProfileBloc>();
        if (profileBloc.state.profileStatus.isIdle || profileBloc.state.profileStatus.isError) {
          profileBloc.add(const ProfileEvent.getProfileRequested());
        }
      },
      child: const Scaffold(
        body: Center(
          child: AppCircleLoader(size: 50),
        ),
      ),
    );
  }
}
