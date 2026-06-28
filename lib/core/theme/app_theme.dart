import 'package:flutter/material.dart';
import 'colors.dart';
import 'chat_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightTextPrimary,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerColor: AppColors.lightDivider,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevent color change on scroll
      ),
      extensions: const [
        ChatThemeExtension(
          userBubbleColor: AppColors.lightUserBubble,
          botBubbleColor: AppColors.lightBotBubble,
          codeBackground: AppColors.lightCodeBackground,
          inputBackground: AppColors.lightBackground,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerColor: AppColors.darkDivider,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extensions: const [
        ChatThemeExtension(
          userBubbleColor: AppColors.darkUserBubble,
          botBubbleColor: AppColors.darkBotBubble,
          codeBackground: AppColors.darkCodeBackground,
          inputBackground: AppColors.darkSurface, // Slightly elevated input
        ),
      ],
    );
  }
}
