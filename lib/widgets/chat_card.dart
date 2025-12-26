import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/chat_session_model.dart';
import '../utils/date_formatter.dart';
import 'avatar_widget.dart';

/// A card widget displaying a chat session preview with unread badge and pin icon.
class ChatCard extends StatelessWidget {
  final ChatSessionModel session;
  final VoidCallback? onTap;
  final void Function(String word)? onWordTap;
  final int index;

  const ChatCard({
    super.key,
    required this.session,
    this.onTap,
    this.onWordTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUnread = session.hasUnread;
    final unreadCount = session.unreadCount;
    final isPinned = session.isPinned;

    return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarWidget(name: session.user.fullName, size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              session.user.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.formatRelativeTime(
                              session.lastActivity,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasUnread
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.lastMessagePreview,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: hasUnread
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          // Show pinned icon
                          if (isPinned) ...[
                            const SizedBox(width: 8),
                            FaIcon(
                              FontAwesomeIcons.thumbtack,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                          ],
                          // Show unread badge
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (30 * index).ms)
        .slideX(
          begin: 0.05,
          duration: 300.ms,
          delay: (30 * index).ms,
          curve: Curves.easeOutCubic,
        );
  }
}
