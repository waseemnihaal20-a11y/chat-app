import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/user_model.dart';
import '../utils/date_formatter.dart';
import 'avatar_widget.dart';

/// A card widget displaying user information for the users list.
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final int index;
  final bool isOnline;
  final String? lastSeenText;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.index = 0,
    this.isOnline = false,
    this.lastSeenText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Simulate online status based on user index
    final showOnline = index % 3 == 0;
    final statusText = showOnline
        ? 'Online'
        : (lastSeenText ?? DateFormatter.formatRelativeTime(user.createdAt));

    return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    AvatarWidget(name: user.fullName, size: 52),
                    if (showOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: showOnline
                              ? const Color(0xFF22C55E)
                              : colorScheme.onSurfaceVariant,
                        ),
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
