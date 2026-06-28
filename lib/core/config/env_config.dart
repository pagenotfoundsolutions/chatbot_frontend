class EnvConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  // Feature Flags
  static const bool enableAuth = bool.fromEnvironment(
    'ENABLE_AUTH',
    defaultValue: true,
  );

  static const bool enableChat = bool.fromEnvironment(
    'ENABLE_CHAT',
    defaultValue: true,
  );

  static const bool enableProfile = bool.fromEnvironment(
    'ENABLE_PROFILE',
    defaultValue: true,
  );
}
