import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/url_constants.dart';
import '../../../../core/network/resp.dart';
import '../models/request/login_request.dart';
import '../models/request/register_request.dart';
import '../models/response/register_result.dart';
import '../models/response/token_response.dart';
import '../models/request/verify_otp_request.dart';
import '../models/request/resend_otp_request.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST(UrlConstants.loginPath)
  Future<Resp<TokenResponse>> login(@Body() LoginRequest request);

  @POST(UrlConstants.registerPath)
  Future<Resp<RegisterResult>> register(@Body() RegisterRequest request);

  @POST('/auth/verify-otp')
  Future<Resp<dynamic>> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/auth/resend-otp')
  Future<Resp<dynamic>> resendOtp(@Body() ResendOtpRequest request);

  // TODO: Uncomment when backend endpoints are ready
  // @POST('/auth/forgot-password')
  // Future<Resp<void>> requestPasswordReset(@Body() Map<String, dynamic> body);

  // @POST('/auth/reset-password')
  // Future<Resp<void>> resetPassword(@Body() Map<String, dynamic> body);
}
