#!/bin/bash
# 1. Update chat_injection.dart
sed -i 's/import '"'"'presentation\/bloc\/chat_bloc.dart'"'"';/import '"'"'domain\/usecases\/create_conversation.dart'"'"';\nimport '"'"'presentation\/bloc\/chat_bloc.dart'"'"';/' lib/features/chat/chat_injection.dart

# Add CreateConversationUseCase to ChatBloc
sed -i 's/cancelMessageUseCase: sl(),/cancelMessageUseCase: sl(),\n        createConversationUseCase: sl(),/' lib/features/chat/chat_injection.dart

