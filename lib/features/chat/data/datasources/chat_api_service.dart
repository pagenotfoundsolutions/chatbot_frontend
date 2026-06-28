import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/page_resp.dart';
import '../../../../core/network/resp.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/send_message_result_model.dart';
import '../models/send_message_request.dart';

part 'chat_api_service.g.dart';

@RestApi()
abstract class ChatApiService {
  factory ChatApiService(Dio dio, {String baseUrl}) = _ChatApiService;

  @GET(ApiConstants.getChats)
  Future<Resp<PageResp<ConversationModel>>> getConversations({
    @Query('page') int page = 1,
    @Query('size') int size = 20,
  });

  @POST(ApiConstants.createChat)
  Future<Resp<ConversationModel>> createConversation({
    @Body() Map<String, dynamic> request = const {},
  });

  @GET(ApiConstants.conversationById)
  Future<Resp<ConversationModel>> getConversation(
    @Path('conversation_id') String conversationId,
  );

  @PUT(ApiConstants.conversationById)
  Future<Resp<ConversationModel>> updateConversation(
    @Path('conversation_id') String conversationId,
    @Body() Map<String, dynamic> request,
  );

  @DELETE(ApiConstants.conversationById)
  Future<Resp<void>> deleteConversation(
    @Path('conversation_id') String conversationId,
  );

  @GET(ApiConstants.conversationMessages)
  Future<Resp<PageResp<MessageModel>>> getMessages(
    @Path('conversation_id') String conversationId, {
    @Query('page') int page = 1,
    @Query('size') int size = 10,
  });

  @POST(ApiConstants.conversationMessages)
  Future<Resp<SendMessageResultModel>> sendMessage(
    @Path('conversation_id') String conversationId,
    @Body() SendMessageRequest request,
  );

  @POST(ApiConstants.cancelMessage)
  Future<Resp<String>> cancelMessage(
    @Path('conversation_id') String conversationId,
  );
}
