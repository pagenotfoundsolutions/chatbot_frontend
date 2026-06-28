import 'dart:io';

void main() {
  final file = File('lib/features/chat/presentation/bloc/chat_event.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('const factory ChatEvent.opened(String conversationId) = ChatEventOpened;', 'const factory ChatEvent.opened(String conversationId) = ChatEventOpened;\n  const factory ChatEvent.reset() = ChatEventReset;');
  file.writeAsStringSync(content);
}
