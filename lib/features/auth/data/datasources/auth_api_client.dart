import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/resp.dart';
import '../models/request/login_request.dart';
import '../models/request/register_request.dart';
import '../models/response/register_result.dart';
import '../models/response/token_response.dart';
import '../models/request/verify_otp_request.dart';
import '../models/request/resend_otp_request.dart';
import '../models/request/refresh_request.dart';
import '../models/request/logout_request.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST(ApiConstants.login)
  Future<Resp<TokenResponse>> login(@Body() LoginRequest request);

  @POST(ApiConstants.register)
  Future<Resp<RegisterResult>> register(@Body() RegisterRequest request);

  @POST(ApiConstants.verifyOtp)
  Future<Resp<dynamic>> verifyOtp(@Body() VerifyOtpRequest request);

  @POST(ApiConstants.resendOtp)
  Future<Resp<dynamic>> resendOtp(@Body() ResendOtpRequest request);

  // TODO: Uncomment when backend endpoints are ready
  // @POST(ApiConstants.forgotPassword)
  // Future<Resp<void>> requestPasswordReset(@Body() Map<String, dynamic> body);

  // @POST(ApiConstants.resetPassword)
  // Future<Resp<void>> resetPassword(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.refreshToken)
  Future<Resp<TokenResponse>> refresh(@Body() RefreshRequest request);

  @POST(ApiConstants.logout)
  Future<Resp<void>> logout(@Body() LogoutRequest request);
}
