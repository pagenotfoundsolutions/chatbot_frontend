import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/resp.dart';
import '../../domain/entities/profile.dart';
import '../models/request/create_profile_request.dart';
import '../models/request/update_profile_request.dart';

part 'profile_api_client.g.dart';

@RestApi()
abstract class ProfileApiClient {
  factory ProfileApiClient(Dio dio, {String baseUrl}) = _ProfileApiClient;

  @GET('/profiles')
  Future<Resp<Profile>> getProfile();

  @POST('/profiles')
  Future<Resp<Profile>> createProfile(
    @Body() CreateProfileRequest request,
  );

  @PUT('/profiles')
  Future<Resp<Profile>> updateProfile(
    @Body() UpdateProfileRequest request,
  );
}
