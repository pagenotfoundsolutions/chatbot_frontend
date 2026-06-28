import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';

import '../../../../core/network/resp.dart';
import '../models/profile_model.dart';
import '../models/request/create_profile_request.dart';
import '../models/request/update_profile_request.dart';

part 'profile_api_client.g.dart';

@RestApi()
abstract class ProfileApiClient {
  factory ProfileApiClient(Dio dio, {String baseUrl}) = _ProfileApiClient;

  @GET(ApiConstants.userProfile)
  Future<Resp<ProfileModel>> getProfile();

  @POST(ApiConstants.createProfile)
  Future<Resp<ProfileModel>> createProfile(
    @Body() CreateProfileRequest request,
  );

  @PUT(ApiConstants.updateProfile)
  Future<Resp<ProfileModel>> updateProfile(
    @Body() UpdateProfileRequest request,
  );
}
