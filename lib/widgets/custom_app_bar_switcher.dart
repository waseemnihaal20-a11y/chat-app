import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/navigation_provider.dart';

/// A custom iOS-style segmented control switcher for the app bar.
/// Uses a sliding indicator similar to CupertinoSlidingSegmentedControl.
class CustomAppBarSwitcher extends StatelessWidget {
  const CustomAppBarSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<NavigationProvider, ChatProvider>(
      builder: (context, navProvider, chatProvider, child) {
        final isUsersTab = navProvider.isUsersListTab;
        final unreadChatsCount = chatProvider.unreadChatsCount;

        return Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Sliding indicator with gradient
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        left: isUsersTab ? 4 : constraints.maxWidth / 2 + 4,
                        top: 4,
                        bottom: 4,
                        width: constraints.maxWidth / 2 - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tab buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              context: context,
                              label: 'Users',
                              icon: FontAwesomeIcons.users,
                              isSelected: isUsersTab,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                navProvider.setHomeTab(HomeTab.usersList);
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              context: context,
                              label: 'Chat History',
                              icon: FontAwesomeIcons.clockRotateLeft,
                              isSelected: !isUsersTab,
                              badgeCount: unreadChatsCount,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                navProvider.setHomeTab(HomeTab.chatHistory);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.2, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            // Show badge for unread chats count
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ).animate().scale(duration: 200.ms),
            ],
          ],
        ),
      ),
    );
  }
}
