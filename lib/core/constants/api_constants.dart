class ApiConstants {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleSignIn = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Chat Endpoints
  static const String getChats = '/chats';
  static const String createChat = '/chats/create';
  static const String sendMessage =
      '/chats/message'; // WebSockets usually have a different path

  // User Endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
