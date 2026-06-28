import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/auth_layout.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/create_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/presentation/bloc/conversations_bloc.dart';
import '../../features/ai_models/presentation/bloc/ai_providers_bloc.dart';
import '../../features/chat/presentation/pages/chat_layout.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/files/presentation/bloc/files_bloc.dart';
import 'router_refresh_stream.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> authNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'auth');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: Listenable.merge([
    GoRouterRefreshStream(sl<AuthBloc>().stream),
    GoRouterRefreshStream(sl<ProfileBloc>().stream),
  ]),
  redirect: (context, state) {
    final authState = sl<AuthBloc>().state;
    final profileState = sl<ProfileBloc>().state;
    
    final currentUri = state.uri.toString();
    final isAuthRoute = currentUri.startsWith('/auth');
    final isSplash = currentUri == '/splash';
    final isCreateProfile = currentUri == '/profile/create';

    // 1. If auth state is unknown (idle/loading) → stay on splash
    if (authState.authStatus.isIdle || authState.authStatus.isLoading) {
      if (!isSplash && !isAuthRoute) {
        return '/splash';
      }
      return null;
    }

    // 2. If user is NOT authenticated (error = no token / login failed)
    if (authState.authStatus.isError) {
      if (!isAuthRoute) {
        return '/auth/login';
      }
      return null;
    }

    // 3. If user IS authenticated
    if (authState.authStatus.isSuccess) {
      // Check profile state
      if (profileState.profileStatus.isIdle || profileState.profileStatus.isLoading) {
        // If we already have a profile loaded (e.g., background refresh), don't redirect
        if (profileState.profileStatus.hasData) {
          // But still redirect away from splash/auth routes
          if (isAuthRoute || isSplash) {
            return '/home';
          }
          return null; 
        }
        
        // Otherwise, user is booting up — show splash
        if (!isSplash) {
          return '/splash';
        }
        return null;
      }

      if (profileState.profileStatus.isError) {
        final msg = profileState.profileStatus.message.toLowerCase();
        if (msg.contains('not found') || msg.contains('404')) {
          if (!isCreateProfile) {
            return '/profile/create';
          }
          return null;
        } else {
          // General profile error (e.g. network) - stay on splash to retry
          if (!isSplash) {
             return '/splash';
          }
          return null;
        }
      }

      if (profileState.profileStatus.isSuccess) {
        // Logged in AND profile exists!
        // If they are on auth/splash/create-profile, redirect to home
        if (isAuthRoute || isSplash || isCreateProfile) {
          return '/home';
        }
        return null; // allow them to go to the requested protected route
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>.value(value: sl<ProfileBloc>()),
            BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
          ],
          child: const SplashPage(),
        );
      },
    ),
    // Auth routes (login, register, OTP, etc.)
    ShellRoute(
      navigatorKey: authNavigatorKey,
      builder: (context, state, child) {
        return BlocProvider<AuthBloc>.value(
          value: sl<AuthBloc>(),
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
          redirect: (context, state) {
            final email = sl<AuthBloc>().state.registeredEmail;
            if (email == null || email.isEmpty) {
              return '/auth/login';
            }
            return null;
          },
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
    // Create profile — standalone route (no chat/file blocs needed)
    GoRoute(
      path: '/profile/create',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>.value(value: sl<ProfileBloc>()),
            BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
          ],
          child: const CreateProfilePage(),
        );
      },
    ),
    // Main app routes (protected — require auth + profile)
    ShellRoute(
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
            BlocProvider<ProfileBloc>.value(value: sl<ProfileBloc>()),
            BlocProvider<ConversationsBloc>.value(value: sl<ConversationsBloc>()),
            BlocProvider<ChatBloc>.value(value: sl<ChatBloc>()),
            BlocProvider<FilesBloc>.value(value: sl<FilesBloc>()),
            BlocProvider<AiProvidersBloc>.value(value: sl<AiProvidersBloc>()),
          ],
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey('ChatLayout'),
            child: ChatLayout(),
          ),
        ),
        GoRoute(
          path: '/chat/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            return NoTransitionPage(
              key: const ValueKey('ChatLayout'),
              child: ChatLayout(conversationId: id),
            );
          },
        ),
        GoRoute(
          path: '/chats',
          builder: (context, state) => const ConversationsPage(),
        ),
      ],
    ),
  ],
);
