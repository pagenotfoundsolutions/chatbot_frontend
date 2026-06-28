import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;
import '../../domain/entities/chat_stream_event.dart';
import '../models/send_message_request.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';

abstract class ChatStreamDataSource {
  Stream<ChatStreamEvent> streamMessage(String conversationId, SendMessageRequest request, {CancelToken? cancelToken});
}

class ChatStreamDataSourceImpl implements ChatStreamDataSource {
  final Dio dio;
  final LocalStorage localStorage;

  ChatStreamDataSourceImpl({required this.dio, required this.localStorage});

  @override
  Stream<ChatStreamEvent> streamMessage(String conversationId, SendMessageRequest request, {CancelToken? cancelToken}) {
    final controller = StreamController<ChatStreamEvent>();
    
    _fetchStream(conversationId, request, controller, cancelToken);
    
    return controller.stream;
  }

  Future<void> _fetchStream(
    String conversationId,
    SendMessageRequest request,
    StreamController<ChatStreamEvent> controller,
    CancelToken? cancelToken,
  ) async {
    bool isCancelled = false;
    web.ReadableStreamDefaultReader? reader;

    // Listen for Dio CancelToken cancellation
    if (cancelToken != null) {
      cancelToken.whenCancel.then((_) {
        isCancelled = true;
        reader?.cancel().toDart.ignore();
        if (!controller.isClosed) controller.close();
      }).ignore();
    }

    final token = localStorage.getString(AppConstants.accessTokenKey);
    final url = '${EnvConfig.apiUrl}${ApiConstants.streamMessage(conversationId)}';
    final body = jsonEncode(request.toJson());

    try {
      final jsHeaders = web.Headers();
      jsHeaders.append('Content-Type', 'application/json');
      jsHeaders.append('Accept', 'text/event-stream');
      if (token != null && token.isNotEmpty) {
        jsHeaders.append('Authorization', 'Bearer $token');
      }

      final fetchInit = web.RequestInit(
        method: 'POST',
        headers: jsHeaders,
        body: body.toJS,
      );

      final response = await web.window.fetch(url.toJS, fetchInit).toDart;

      if (!response.ok) {
        controller.add(ChatStreamEvent.error('HTTP ${response.status}: ${response.statusText}'));
        await controller.close();
        return;
      }

      final readableStream = response.body;
      if (readableStream == null) {
        controller.add(ChatStreamEvent.error('No response body'));
        await controller.close();
        return;
      }

      reader = readableStream.getReader() as web.ReadableStreamDefaultReader;
      final decoder = const Utf8Decoder(allowMalformed: true);
      String buffer = '';
      String currentEvent = '';

      while (!isCancelled) {
        final result = await reader.read().toDart;

        if (result.done) break;

        final chunk = result.value;
        if (chunk == null) continue;

        // Convert JS Uint8Array to Dart Uint8List
        final bytes = (chunk as JSUint8Array).toDart;
        buffer += decoder.convert(bytes);

        // Process complete lines from buffer
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7);
          } else if (line.startsWith('data: ')) {
            final dataString = line.substring(6);
            try {
              final data = jsonDecode(dataString) as Map<String, dynamic>;

              if (currentEvent == 'token') {
                controller.add(ChatStreamEvent.token(data['content'] as String));
              } else if (currentEvent == 'thinking') {
                controller.add(ChatStreamEvent.thinking(data['content'] as String));
              } else if (currentEvent == 'done') {
                controller.add(ChatStreamEvent.done(data['conversation_id'] as String));
              } else if (currentEvent == 'error') {
                controller.add(ChatStreamEvent.error(data['detail'] as String? ?? 'Streaming error'));
              }
            } catch (_) {
              // Ignore parse errors for broken SSE chunks
            }
          }
        }
      }
    } catch (e) {
      if (!isCancelled && !controller.isClosed) {
        controller.add(ChatStreamEvent.error(e.toString()));
      }
    } finally {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }
}
