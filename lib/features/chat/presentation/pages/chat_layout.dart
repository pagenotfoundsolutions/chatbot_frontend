import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_page.dart';
import 'conversations_page.dart';
import '../../../ai_models/presentation/bloc/ai_providers_bloc.dart';
import '../../../ai_models/presentation/bloc/ai_providers_event.dart';

class ChatLayout extends StatefulWidget {
  final String? conversationId;

  const ChatLayout({super.key, this.conversationId});

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    
    final aiState = context.read<AiProvidersBloc>().state;
    if (aiState.providers.isEmpty && !aiState.isLoading) {
      context.read<AiProvidersBloc>().add(const AiProvidersEvent.fetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we are on mobile, standard routing takes place.
    // However, if we are at the root '/home' (or '/chats'), we just show the list.
    
    return context.responsive.value<Widget>(
      mobile: () {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: SafeArea(
              child: ConversationsPage(
                isSidebar: true,
                activeConversationId: widget.conversationId,
                onConversationTap: (id) {
                  Navigator.of(context).pop(); // Close drawer
                  context.go('/chat/$id');
                },
              ),
            ),
          ),
          body: widget.conversationId == null
              ? ChatPage(
                  key: const ValueKey('new_chat'),
                  conversationId: null,
                  showBackButton: false,
                  showDrawerButton: true,
                  onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : ChatPage(
                  key: ValueKey(widget.conversationId),
                  conversationId: widget.conversationId!,
                  showBackButton: false,
                  showDrawerButton: true,
                  onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
      },
      tablet: () => _buildTabletDesktopLayout(context),
      desktop: () => _buildTabletDesktopLayout(context),
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 320.w, // Fixed sidebar width
            child: ConversationsPage(
              isSidebar: true,
              activeConversationId: widget.conversationId,
              onConversationTap: (id) {
                context.go('/chat/$id');
              },
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: widget.conversationId == null
                ? const ChatPage(
                    key: ValueKey('new_chat'),
                    conversationId: null,
                    showBackButton: false,
                  )
                : ChatPage(
                    key: ValueKey(widget.conversationId), // Force rebuild on id change
                    conversationId: widget.conversationId!,
                    showBackButton: false,
                  ),
          ),
        ],
      ),
    );
  }

}
