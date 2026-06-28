import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/loading_state.dart';
import '../widgets/profile_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileEvent.getProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: BlocConsumer<ProfileBloc, ProfileState>(
                  listenWhen: (p, c) => p.updateStatus != c.updateStatus,
                  listener: (context, state) {
                    state.updateStatus.maybeWhen(
                      success: (msg, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.green),
                        );
                      },
                      error: (msg, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.red),
                        );
                      },
                      orElse: () {},
                    );
                  },
                  builder: (context, state) {
                    return state.profileStatus.maybeWhen(
                      loading: (_) => const Center(child: CircularProgressIndicator()),
                      success: (_, profile) {
                        if (profile == null) return const SizedBox();
                        return ProfileForm(
                          isCreating: false,
                          initialName: profile.name,
                          initialProfileImageUrl: profile.profileImageUrl,
                          initialDob: profile.dob,
                          isLoading: state.updateStatus.isLoading,
                        );
                      },
                      error: (msg, _) => Center(
                        child: Text('Error loading profile: $msg', style: const TextStyle(color: Colors.red)),
                      ),
                      orElse: () => const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
