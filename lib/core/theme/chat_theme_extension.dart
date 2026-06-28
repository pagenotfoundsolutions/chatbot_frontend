import 'package:flutter/material.dart';

/// A ThemeExtension that holds specific colors for Chatbot elements.
/// This allows us to access these colors natively via `Theme.of(context).extension<ChatThemeExtension>()`
class ChatThemeExtension extends ThemeExtension<ChatThemeExtension> {
  final Color userBubbleColor;
  final Color botBubbleColor;
  final Color codeBackground;
  final Color inputBackground;

  const ChatThemeExtension({
    required this.userBubbleColor,
    required this.botBubbleColor,
    required this.codeBackground,
    required this.inputBackground,
  });

  @override
  ThemeExtension<ChatThemeExtension> copyWith({
    Color? userBubbleColor,
    Color? botBubbleColor,
    Color? codeBackground,
    Color? inputBackground,
  }) {
    return ChatThemeExtension(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      botBubbleColor: botBubbleColor ?? this.botBubbleColor,
      codeBackground: codeBackground ?? this.codeBackground,
      inputBackground: inputBackground ?? this.inputBackground,
    );
  }

  @override
  ThemeExtension<ChatThemeExtension> lerp(
    covariant ThemeExtension<ChatThemeExtension>? other,
    double t,
  ) {
    if (other is! ChatThemeExtension) {
      return this;
    }
    return ChatThemeExtension(
      userBubbleColor: Color.lerp(userBubbleColor, other.userBubbleColor, t)!,
      botBubbleColor: Color.lerp(botBubbleColor, other.botBubbleColor, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
    );
  }
}
