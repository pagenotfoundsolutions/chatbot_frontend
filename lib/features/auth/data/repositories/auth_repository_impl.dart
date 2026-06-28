import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_client.dart';
import '../datasources/google_auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/request/login_request.dart';
import '../models/request/register_request.dart';
import '../models/request/verify_otp_request.dart';
import '../models/request/resend_otp_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient apiClient;
  final GoogleAuthRemoteDataSource googleAuthRemoteDataSource;
  final LocalStorage localStorage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.googleAuthRemoteDataSource,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    return safeApiCall(() async {
      final response = await apiClient.login(LoginRequest(email: email, password: password));
      if (response.success && response.data != null) {
        final token = response.data!.accessToken;
        await localStorage.saveString(AppConstants.accessTokenKey, token);
        return UserModel(
          id: '',
          email: email,
          name: '',
          token: token,
        );
      } else {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, void>> register(String email, String password) async {
    return safeApiCall(() async {
      final response = await apiClient.register(RegisterRequest(email: email, password: password));
      if (!response.success) {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, void>> verifyOtp(String email, String otp) async {
    return safeApiCall(() async {
      final response = await apiClient.verifyOtp(VerifyOtpRequest(email: email, otpCode: otp));
      if (!response.success) {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, void>> resendOtp(String email) async {
    return safeApiCall(() async {
      final response = await apiClient.resendOtp(ResendOtpRequest(email: email));
      if (!response.success) {
        throw Exception(response.message);
      }
    });
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    return safeApiCall(() async {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      // TODO: Replace with real api call: await apiClient.requestPasswordReset({'email': email});
    });
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email, String otp, String newPassword) async {
    return safeApiCall(() async {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      if (otp != '123456') {
        throw Exception('Invalid OTP');
      }
      
      // TODO: Replace with real api call: await apiClient.resetPassword({'email': email, 'otp': otp, 'newPassword': newPassword});
    });
  }

  @override
  Future<Either<Failure, User>> googleSignIn() async {
    return safeApiCall(() async {
      // 1. Get Google ID Token from Google SDK
      final googleAuthResult = await googleAuthRemoteDataSource.googleSignIn();
      
      // 2. Send ID Token to our Backend API
      // TODO: Replace with real backend call when ready:
      // final response = await apiClient.googleLogin(GoogleLoginRequest(idToken: googleAuthResult.idToken));
      
      // Mocking backend response for now:
      const backendAccessToken = 'mock_jwt_from_our_backend';

      // 3. Save our Backend Token
      await localStorage.saveString(AppConstants.accessTokenKey, backendAccessToken);
      
      return UserModel(
        id: googleAuthResult.id,
        email: googleAuthResult.email,
        name: googleAuthResult.displayName,
        token: backendAccessToken,
      );
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return safeApiCall(() async {
      await googleAuthRemoteDataSource.googleSignOut();
      await localStorage.clear();
    });
  }
}
