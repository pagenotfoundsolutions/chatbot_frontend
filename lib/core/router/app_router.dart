import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/env_config.dart';
import '../di/injection.dart';
import '../../features/auth/auth_injection.dart' hide sl;
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/auth_layout.dart';
import '../../features/profile/profile_injection.dart' hide sl;
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/create_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_check_layout.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> authNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'auth');

bool _isAuthInitialized = false;
bool _isProfileInitialized = false;

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/auth/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/auth/login',
    ),
    ShellRoute(
      navigatorKey: authNavigatorKey,
      builder: (context, state, child) {
        if (!EnvConfig.enableAuth) {
          return const Scaffold(
            body: Center(child: Text('Auth Module Disabled via Dart-Define')),
          );
        }

        if (!_isAuthInitialized) {
          initAuth();
          _isAuthInitialized = true;
        }

        return BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
          child: AuthLayout(child: child),
        );
      },
      routes: [
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/auth/verify-otp',
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/auth/reset-password',
          builder: (context, state) => const ResetPasswordPage(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        if (!_isProfileInitialized) {
          initProfile();
          _isProfileInitialized = true;
        }
        return BlocProvider<ProfileBloc>(
          create: (context) => sl<ProfileBloc>(),
          child: ProfileCheckLayout(child: child),
        );
      },
      routes: [
        GoRoute(
          path: '/profile-check',
          builder: (context, state) => const ProfileCheckScreen(),
        ),
        GoRoute(
          path: '/create-profile',
          builder: (context, state) => const CreateProfilePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home / Chat Screen (Pending)')),
          ),
        ),
      ],
    ),
  ],
);
