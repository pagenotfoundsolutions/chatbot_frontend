class UrlConstants {
  UrlConstants._();

  // Add specific URL endpoints here as needed.
  // Base URL is managed via EnvConfig, but specific paths can go here.
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String verifyOtpPath = '/auth/verify-otp';
  static const String refreshTokenPath = '/auth/refresh';
}
