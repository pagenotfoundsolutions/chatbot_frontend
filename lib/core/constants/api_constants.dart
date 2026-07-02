class ApiConstants {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleSignIn = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Chat Endpoints
  static const String getChats = '/chats';
  static const String createChat = '/chats';
  static const String conversationById = '/chats/{conversation_id}';
  static const String conversationMessages = '/chats/{conversation_id}/messages';
  static const String cancelMessage = '/chats/{conversation_id}/messages/cancel';
  static const String streamMessagePath = '/chats/{conversation_id}/messages/stream';
  static String streamMessage(String conversationId) => '/chats/$conversationId/messages/stream';
  
  // AI Models Endpoints
  static const String getAiProvidersWithModels = '/ai/providers/with-active-models';

  // File Endpoints
  static const String uploadFile = '/files/upload';
  static const String listFiles = '/files';
  static const String getFileDetail = '/files/detail/{file_id}';
  static const String deleteFile = '/files/{file_id}';

  // User Endpoints
  // Profile Endpoints
  static const String userProfile = '/profiles';
  static const String createProfile = '/profiles';
  static const String updateProfile = '/profiles';

  // Timeouts
  static const int connectTimeout = 1200000; // 20 minutes
  static const int receiveTimeout = 1200000; // 20 minutes
}
