import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// Main screen with animated bottom navigation for the three tabs.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: IndexedStack(
              key: ValueKey(navProvider.currentBottomNavIndex),
              index: navProvider.currentBottomNavIndex,
              children: [
                const HomeScreen(),
                const _OffersPlaceholder(),
                const SettingsScreen(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: navProvider.currentBottomNavIndex,
              onDestinationSelected: (index) {
                HapticFeedback.selectionClick();
                navProvider.setBottomNavIndex(index);
              },
              animationDuration: const Duration(milliseconds: 400),
              destinations: [
                _buildNavDestination(
                  context: context,
                  icon: FontAwesomeIcons.message,
                  selectedIcon: FontAwesomeIcons.solidMessage,
                  label: 'Home',
                  isSelected: navProvider.currentBottomNavIndex == 0,
                ),
                _buildNavDestination(
                  context: context,
                  icon: FontAwesomeIcons.tag,
                  selectedIcon: FontAwesomeIcons.tags,
                  label: 'Offers',
                  isSelected: navProvider.currentBottomNavIndex == 1,
                ),
                _buildNavDestination(
                  context: context,
                  icon: FontAwesomeIcons.gear,
                  selectedIcon: FontAwesomeIcons.gears,
                  label: 'Settings',
                  isSelected: navProvider.currentBottomNavIndex == 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

NavigationDestination _buildNavDestination({
  required BuildContext context,
  required IconData icon,
  required IconData selectedIcon,
  required String label,
  required bool isSelected,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return NavigationDestination(
    icon: FaIcon(icon, size: 20, color: colorScheme.onSurfaceVariant),
    selectedIcon: FaIcon(selectedIcon, size: 20, color: colorScheme.primary)
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        ),
    label: label,
  );
}

/// Placeholder for Offers tab
class _OffersPlaceholder extends StatelessWidget {
  const _OffersPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Offers'), centerTitle: true),
      body: Center(
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.tag,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Offers',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon...',
                      style: theme.textTheme.bodyLarge?.copyWith(
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
}
