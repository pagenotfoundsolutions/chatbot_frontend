import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../../../core/utils/loading_state.dart';
import '../../../auth/presentation/widgets/animated_background.dart';
import '../../../auth/presentation/widgets/glass_container.dart';
import '../widgets/profile_form.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          const Positioned.fill(
            child: AnimatedBackground(),
          ),

          // 2. Responsive Content
          Positioned.fill(
            child: context.responsive.value<Widget>(
              mobile: () => _buildMobileLayout(context),
              tablet: () => _buildTabletLayout(context),
              desktop: () => _buildDesktopLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWelcomeHeader(context),
              SizedBox(height: 32.h),
              _buildGlassFormContainer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWelcomeHeader(context),
            SizedBox(height: 32.h),
            SizedBox(
              width: 500,
              child: _buildGlassFormContainer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: Center(
              child: _buildWelcomeIllustration(context),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                width: 480,
                child: _buildGlassFormContainer(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.person_add_rounded,
          size: 64.r,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        SizedBox(height: 12.h),
        Text(
          'Welcome! 👋',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Set up your profile to get started',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeIllustration(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_circle_rounded,
          size: 180.r,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
        SizedBox(height: 24.h),
        Text(
          'Almost there!',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create your profile to start chatting\nwith AI assistants',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassFormContainer(BuildContext context) {
    return GlassContainer(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (p, c) => p.createStatus != c.createStatus,
          listener: (context, state) {
            state.createStatus.maybeWhen(
              success: (msg, _) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.go('/home');
              },
              error: (msg, _) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
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
    );
  }
}
