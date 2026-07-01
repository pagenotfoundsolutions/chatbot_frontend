import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/chat_api_service.dart';
import 'data/datasources/chat_stream_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/create_conversation.dart';
import 'domain/usecases/delete_conversation.dart';
import 'domain/usecases/get_conversation.dart';
import 'domain/usecases/get_conversations.dart';
import 'domain/usecases/get_messages.dart';
import 'domain/usecases/send_message.dart';
import 'domain/usecases/stream_message.dart';
import 'domain/usecases/cancel_message.dart';
import 'domain/usecases/update_conversation.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'presentation/bloc/conversations_bloc.dart';

final sl = GetIt.instance;

void initChat() {
  if (!sl.isRegistered<ChatApiService>()) {
    sl.registerLazySingleton<ChatApiService>(() => ChatApiService(sl<Dio>()));
  }

  if (!sl.isRegistered<ChatStreamDataSource>()) {
    sl.registerLazySingleton<ChatStreamDataSource>(() => ChatStreamDataSourceImpl(dio: sl<Dio>(), localStorage: sl()));
  }

  // Repository
  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(apiService: sl(), streamDataSource: sl()),
    );
  }

  // Use cases
  if (!sl.isRegistered<GetConversationsUseCase>()) {
    sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
    sl.registerLazySingleton(() => GetConversationUseCase(sl()));
    sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
    sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
    sl.registerLazySingleton(() => UpdateConversationUseCase(sl()));
    sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
    sl.registerLazySingleton(() => SendMessageUseCase(sl()));
    sl.registerLazySingleton(() => StreamMessageUseCase(sl()));
    sl.registerLazySingleton(() => CancelMessageUseCase(sl()));
  }

  // BLoCs
  if (!sl.isRegistered<ConversationsBloc>()) {
    sl.registerLazySingleton(
      () => ConversationsBloc(
        getConversationsUseCase: sl(),
        createConversationUseCase: sl(),
        deleteConversationUseCase: sl(),
        updateConversationUseCase: sl(),
      ),
    );
  }
  
  if (!sl.isRegistered<ChatBloc>()) {
    sl.registerLazySingleton(
      () => ChatBloc(
        getMessagesUseCase: sl(),
        streamMessageUseCase: sl(),
        cancelMessageUseCase: sl(),
        createConversationUseCase: sl(),
      ),
    );
  }
}
