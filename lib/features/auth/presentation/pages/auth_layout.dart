import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/loading_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          const Positioned.fill(
            child: AnimatedBackground(),
          ),

          // 2. Responsive Content Layout
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
              _buildLottieAnimation(context: context, height: 250.h),
              SizedBox(height: 40.h),
              _buildGlassContainer(context),
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
            _buildLottieAnimation(context: context, height: 300.h),
            SizedBox(height: 40.h),
            SizedBox(
              width: 500,
              child: _buildGlassContainer(context),
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
              child: _buildLottieAnimation(context: context, height: 500.h),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                width: 450,
                child: _buildGlassContainer(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLottieAnimation({required BuildContext context, required double height}) {
    return Lottie.network(
      AssetConstants.aiTechLottieUrl,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a nice tech icon if the network animation fails to load
        return SizedBox(
          height: height,
          child: Center(
            child: Icon(
              Icons.smart_toy_outlined,
              size: height * 0.6,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
        );
      },
    );
  }

  void _showError(BuildContext context, String message) {
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(BuildContext context, String message) {
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildGlassContainer(BuildContext context) {
    return GlassContainer(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.authStatus != c.authStatus,
              listener: (context, state) {
                state.authStatus.maybeWhen(
                  error: (msg, _) {
                    _showError(context, msg);
                    if (msg.toLowerCase().contains('not verified')) {
                      context.go('/auth/verify-otp');
                    }
                  },
                  success: (msg, _) {
                    _showSuccess(context, msg);
                  },
                  orElse: () {},
                );
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.registerStatus != c.registerStatus,
              listener: (context, state) {
                state.registerStatus.maybeWhen(
                  error: (msg, _) => _showError(context, msg),
                  success: (msg, _) {
                    _showSuccess(context, msg);
                    context.go('/auth/verify-otp');
                  },
                  orElse: () {},
                );
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.verifyOtpStatus != c.verifyOtpStatus,
              listener: (context, state) {
                state.verifyOtpStatus.maybeWhen(
                  error: (msg, _) => _showError(context, msg),
                  success: (msg, _) {
                    _showSuccess(context, msg);
                    context.go('/auth/login');
                  },
                  orElse: () {},
                );
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.resendOtpStatus != c.resendOtpStatus,
              listener: (context, state) {
                state.resendOtpStatus.maybeWhen(
                  error: (msg, _) => _showError(context, msg),
                  success: (msg, _) {
                    _showSuccess(context, msg);
                  },
                  orElse: () {},
                );
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.passwordResetRequestStatus != c.passwordResetRequestStatus,
              listener: (context, state) {
                state.passwordResetRequestStatus.maybeWhen(
                  error: (msg, _) => _showError(context, msg),
                  success: (msg, _) {
                    if (msg.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.blue),
                      );
                    }
                    context.go('/auth/reset-password');
                  },
                  orElse: () {},
                );
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.passwordResetStatus != c.passwordResetStatus,
              listener: (context, state) {
                state.passwordResetStatus.maybeWhen(
                  error: (msg, _) => _showError(context, msg),
                  success: (msg, _) {
                    _showSuccess(context, msg);
                    context.go('/auth/login');
                  },
                  orElse: () {},
                );
              },
            ),
          ],
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: child,
          ),
        ),
      ),
    );
  }
}
