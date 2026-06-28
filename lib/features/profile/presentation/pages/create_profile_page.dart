import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/loading_state.dart';
import '../widgets/profile_form.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
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
                  listenWhen: (p, c) => p.createStatus != c.createStatus,
                  listener: (context, state) {
                    state.createStatus.maybeWhen(
                      success: (msg, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.green),
                        );
                        context.go('/home'); // Go to chat/home after creation
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
                    return ProfileForm(
                      isCreating: true,
                      isLoading: state.createStatus.isLoading,
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
