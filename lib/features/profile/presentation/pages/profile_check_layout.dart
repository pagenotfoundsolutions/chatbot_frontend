import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/loading_state.dart';

class ProfileCheckLayout extends StatefulWidget {
  final Widget child;

  const ProfileCheckLayout({super.key, required this.child});

  @override
  State<ProfileCheckLayout> createState() => _ProfileCheckLayoutState();
}

class _ProfileCheckLayoutState extends State<ProfileCheckLayout> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileEvent.getProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (p, c) => p.profileStatus != c.profileStatus,
      listener: (context, state) {
        state.profileStatus.maybeWhen(
          error: (msg, _) {
            if (msg == 'Profile not found') {
              context.go('/create-profile');
            }
          },
          success: (msg, _) {
            // If we are currently on the checking route, redirect to home
            if (GoRouterState.of(context).uri.toString() == '/profile-check') {
              context.go('/home'); // Or chat screen
            }
          },
          orElse: () {},
        );
      },
      child: widget.child,
    );
  }
}

class ProfileCheckScreen extends StatelessWidget {
  const ProfileCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
