import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../../../../core/widgets/app_loader.dart';

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
    return widget.child;
  }
}

class ProfileCheckScreen extends StatelessWidget {
  const ProfileCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppCircleLoader(size: 40),
            const SizedBox(height: 20),
            Text(
              'Setting things up...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
