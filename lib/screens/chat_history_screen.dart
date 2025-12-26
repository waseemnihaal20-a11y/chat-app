import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/chat_card.dart';
import '../widgets/dictionary_bottom_sheet.dart';
import 'chat_screen.dart';

/// Screen displaying the chat history with all conversations.
/// Refreshes timestamps when tab is switched to.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh chat history timestamps when this tab becomes visible
    final navProvider = context.watch<NavigationProvider>();
    if (navProvider.isChatHistoryTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatProvider>().refreshChatHistory();
      });
    }
  }

  void _navigateToChat(BuildContext context, String visibleSessionId) {
    final session = context.read<ChatProvider>().getChatSession(
      visibleSessionId,
    );
    if (session != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChatScreen(user: session.user),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _showDictionaryBottomSheet(BuildContext context, String word) {
    DictionaryBottomSheet.show(context, word);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final sessions = chatProvider.chatSessions;

        if (sessions.isEmpty) {
          return _buildEmptyState(theme, colorScheme);
        }

        return ListView.builder(
          key: const PageStorageKey('chat_history'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return ChatCard(
              session: session,
              index: index,
              onTap: () => _navigateToChat(context, session.id),
              onWordTap: (word) => _showDictionaryBottomSheet(context, word),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.comments,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Conversations Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation from the\nUsers tab!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, duration: 400.ms),
      ),
    );
  }
}
