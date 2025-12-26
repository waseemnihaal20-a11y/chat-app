import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/ios_toggle.dart';

/// Settings screen with dark/light mode toggle and other options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
          return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    context: context,
                    title: 'Appearance',
                    children: [
                      IosToggle(
                        title: 'Dark Mode',
                        icon: FontAwesomeIcons.moon,
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setDarkMode(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context: context,
                    title: 'Notifications',
                    children: [
                      IosToggle(
                        title: 'Push Notifications',
                        icon: FontAwesomeIcons.bell,
                        value: settingsProvider.pushNotificationsEnabled,
                        onChanged: (value) {
                          settingsProvider.setPushNotifications(value);
                        },
                      ),
                      IosToggle(
                        title: 'Message Sounds',
                        icon: FontAwesomeIcons.volumeHigh,
                        value: settingsProvider.messageSoundsEnabled,
                        onChanged: (value) {
                          settingsProvider.setMessageSounds(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context: context,
                    title: 'Privacy',
                    children: [
                      IosToggle(
                        title: 'Read Receipts',
                        icon: FontAwesomeIcons.checkDouble,
                        value: settingsProvider.readReceiptsEnabled,
                        onChanged: (value) {
                          settingsProvider.setReadReceipts(value);
                        },
                      ),
                      IosToggle(
                        title: 'Online Status',
                        icon: FontAwesomeIcons.circle,
                        value: settingsProvider.onlineStatusEnabled,
                        onChanged: (value) {
                          settingsProvider.setOnlineStatus(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context: context,
                    title: 'About',
                    children: [
                      _buildInfoRow(
                        context: context,
                        icon: FontAwesomeIcons.circleInfo,
                        title: 'Version',
                        value: '1.0.0',
                      ),
                    ],
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
