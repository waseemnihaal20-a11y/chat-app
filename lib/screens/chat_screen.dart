import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/dictionary_bottom_sheet.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

/// Screen for individual chat conversations.
class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    // Mark messages as seen when entering the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markSessionAsSeen(widget.user.id);
    });
  }

  @override
  void dispose() {
    // Unfocus to prevent keyboard from opening on return
    _focusNode.unfocus();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      _hasText = hasText;
      (context as Element).markNeedsBuild();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatProvider>().sendMessage(widget.user.id, content);
    _messageController.clear();
    _scrollToBottom();
  }

  void _retryMessage(String messageId) {
    context.read<ChatProvider>().retryMessage(widget.user.id, messageId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showDictionaryBottomSheet(String word) {
    DictionaryBottomSheet.show(context, word);
  }

  void _showChatMenu() {
    final chatProvider = context.read<ChatProvider>();
    final isPinned = chatProvider.isChatPinned(widget.user.id);
    final messages = chatProvider.getMessages(widget.user.id);
    final hasMessages = messages.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.thumbtack,
                size: 18,
                color: colorScheme.primary,
              ),
              title: Text(isPinned ? 'Unpin Chat' : 'Pin Chat'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await ConfirmationDialog.show(
                  context: this.context,
                  title: isPinned ? 'Unpin Chat' : 'Pin Chat',
                  message: isPinned
                      ? 'Remove ${widget.user.fullName} from pinned chats?'
                      : 'Pin ${widget.user.fullName} to the top of your chats?',
                  confirmText: isPinned ? 'Unpin' : 'Pin',
                  icon: FontAwesomeIcons.thumbtack,
                );
                if (confirm) {
                  chatProvider.togglePinChat(widget.user.id);
                  HapticFeedback.mediumImpact();
                }
              },
            ),
            // Only show delete option if there are messages
            if (hasMessages) ...[
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.trash,
                  size: 18,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Delete Chat',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await ConfirmationDialog.show(
                    context: this.context,
                    title: 'Delete Chat',
                    message:
                        'Are you sure you want to delete all messages with ${widget.user.fullName}? This action cannot be undone.',
                    confirmText: 'Delete',
                    icon: FontAwesomeIcons.trash,
                    isDangerous: true,
                  );
                  if (confirm && mounted) {
                    chatProvider.deleteChat(widget.user.id);
                    HapticFeedback.heavyImpact();
                    Navigator.pop(this.context);
                  }
                },
              ),
            ],
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ).animate().slideY(begin: 0.2, duration: 200.ms).fadeIn(duration: 150.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(theme, colorScheme),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(theme, colorScheme)),
          _buildInputArea(theme, colorScheme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
      ),
      title: Row(
        children: [
          AvatarWidget(name: widget.user.fullName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Online',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showChatMenu,
          icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 18),
        ),
      ],
    );
  }

  Widget _buildMessageList(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.getMessages(widget.user.id);
        final session = chatProvider.getChatSession(widget.user.id);
        final isTyping = session?.isTyping ?? false;

        // Mark messages as seen when viewing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          chatProvider.markSessionAsSeen(widget.user.id);
        });

        if (messages.isEmpty && !isTyping) {
          return _buildEmptyChat(theme, colorScheme);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: messages.length + (isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // Show typing indicator at the end
            if (isTyping && index == messages.length) {
              return TypingBubble(userName: widget.user.fullName);
            }

            final message = messages[index];
            return MessageBubble(
              message: message,
              userName: widget.user.fullName,
              index: index,
              onWordLongPress: _showDictionaryBottomSheet,
              onRetry: message.hasFailed
                  ? () => _retryMessage(message.id)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyChat(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(
                      name: widget.user.fullName,
                      size: 80,
                      animate: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Start a conversation with',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Say hello! 👋',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, duration: 400.ms),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton.filled(
                    onPressed: _hasText ? _sendMessage : null,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: _hasText
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      foregroundColor: _hasText
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                )
                .animate(target: _hasText ? 1 : 0)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 150.ms,
                ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, duration: 300.ms);
  }
}
