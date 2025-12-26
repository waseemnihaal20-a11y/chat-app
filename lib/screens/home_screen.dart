import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../widgets/add_user_bottom_sheet.dart';
import '../widgets/custom_app_bar_switcher.dart';
import 'chat_history_screen.dart';
import 'users_list_screen.dart';

/// Home screen with custom tab switcher for Users List and Chat History.
/// Preserves scroll position when switching between tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Page storage bucket to preserve scroll positions
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final currentTab = navProvider.currentHomeTab;
        final tabIndex = currentTab == HomeTab.usersList ? 0 : 1;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  centerTitle: true,
                  title: Text(
                    'Mini Chat',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomAppBarSwitcher()
                    ),
                  ),
                ),
              ];
            },
            body: PageStorage(
              bucket: _bucket,
              child: IndexedStack(
                index: tabIndex,
                children: const [
                  UsersListScreen(key: PageStorageKey('users_list')),
                  ChatHistoryScreen(key: PageStorageKey('chat_history')),
                ],
              ),
            ),
          ),
          floatingActionButton: navProvider.isUsersListTab
              ? FloatingActionButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        AddUserBottomSheet.show(context);
                      },
                      child: const FaIcon(FontAwesomeIcons.userPlus, size: 20),
                    )
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 200.ms)
              : null,
        );
      },
    );
  }
}
