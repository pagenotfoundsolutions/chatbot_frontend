sealed class ChatStreamEvent {
  const ChatStreamEvent();
  
  factory ChatStreamEvent.token(String content) = ChatStreamEventToken;
  factory ChatStreamEvent.thinking(String content) = ChatStreamEventThinking;
  factory ChatStreamEvent.done(String conversationId) = ChatStreamEventDone;
  factory ChatStreamEvent.error(String detail) = ChatStreamEventError;
}

class ChatStreamEventToken extends ChatStreamEvent {
  final String content;
  const ChatStreamEventToken(this.content);
}

class ChatStreamEventThinking extends ChatStreamEvent {
  final String content;
  const ChatStreamEventThinking(this.content);
}

class ChatStreamEventDone extends ChatStreamEvent {
  final String conversationId;
  const ChatStreamEventDone(this.conversationId);
}

class ChatStreamEventError extends ChatStreamEvent {
  final String detail;
  const ChatStreamEventError(this.detail);
}
