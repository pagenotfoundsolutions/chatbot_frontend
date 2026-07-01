import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/resp.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/file_model.dart';

part 'files_api_client.g.dart';

@RestApi()
abstract class FilesApiClient {
  factory FilesApiClient(Dio dio, {String baseUrl}) = _FilesApiClient;

  @POST(ApiConstants.uploadFile)
  @MultiPart()
  Future<Resp<FileModel>> uploadFile(
    @Part(name: 'file') MultipartFile file,
  );

  @GET(ApiConstants.listFiles)
  Future<Resp<List<FileModel>>> getFiles();

  @DELETE(ApiConstants.deleteFile)
  Future<Resp<void>> deleteFile(@Path('file_id') String fileId);
}
