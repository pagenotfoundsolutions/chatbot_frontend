import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'core/di/injection.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Use path URL strategy for web (removes # from URLs)
  usePathUrlStrategy();

  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveInit(
      breakpoints: [
        Breakpoints(
          width: 650,
          deviceType: DeviceType.mobile,
          designSize: const Size(375, 812),
        ),
        Breakpoints(
          width: 1100,
          deviceType: DeviceType.tablet,
          designSize: const Size(768, 1024),
        ),
        Breakpoints(
          width: double.infinity,
          deviceType: DeviceType.desktop,
          designSize: const Size(1440, 900),
          autoScale: false,
        ),
      ],
      builder: (context, child) {
        return BlocProvider(
          create: (context) => di.sl<ThemeCubit>(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'ChatBot',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: appRouter,
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        );
      },
    );
  }
}
