import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/dictionary_provider.dart';

/// A bottom sheet widget for displaying word definitions.
/// Includes pronunciation audio playback like Google Translate.
class DictionaryBottomSheet extends StatelessWidget {
  final String word;

  const DictionaryBottomSheet({super.key, required this.word});

  // Track if a bottom sheet is currently showing to prevent multiples
  static bool _isShowing = false;

  static Future<void> show(BuildContext context, String word) async {
    // Prevent multiple bottom sheets from opening
    if (_isShowing) return;

    _isShowing = true;

    final provider = context.read<DictionaryProvider>();
    await provider.lookupWord(word);

    if (!context.mounted) {
      _isShowing = false;
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DictionaryBottomSheet(word: word),
    );

    provider.clear();
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        return Container(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDragHandle(colorScheme),
                  _buildHeader(context, theme, colorScheme, provider),
                  Flexible(
                    child: _buildContent(context, theme, colorScheme, provider),
                  ),
                ],
              ),
            )
            .animate()
            .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 200.ms);
      },
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DictionaryProvider provider,
  ) {
    final definition = provider.currentDefinition;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition?.word ?? word,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (definition?.bestPhonetic != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    definition!.bestPhonetic!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (provider.hasAudio)
            IconButton.filled(
                  onPressed: provider.isPlayingAudio
                      ? provider.stopAudio
                      : provider.playAudio,
                  icon: Icon(
                    provider.isPlayingAudio
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 1.0,
                  end: provider.isPlayingAudio ? 1.1 : 1.0,
                  duration: 500.ms,
                ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DictionaryProvider provider,
  ) {
    if (provider.isLoading) {
      return _buildLoading(colorScheme);
    }

    if (provider.error != null) {
      return _buildError(theme, colorScheme, provider);
    }

    final definition = provider.currentDefinition;
    if (definition == null) {
      return _buildEmpty(theme, colorScheme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final meaning in definition.meanings)
            _buildMeaning(theme, colorScheme, meaning),
        ],
      ),
    );
  }

  Widget _buildLoading(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1000.ms),
      ),
    );
  }

  Widget _buildError(
    ThemeData theme,
    ColorScheme colorScheme,
    DictionaryProvider provider,
  ) {
    final error = provider.error!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.error.withValues(alpha: 0.7),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            error.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (error.resolution != null) ...[
            const SizedBox(height: 8),
            Text(
              error.resolution!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No definitions available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildMeaning(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic meaning,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              meaning.partOfSpeech,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < meaning.definitions.length && i < 3; i++)
            _buildDefinition(theme, colorScheme, meaning.definitions[i], i + 1),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
    );
  }

  Widget _buildDefinition(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic def,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.definition, style: theme.textTheme.bodyMedium),
                if (def.example != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: colorScheme.primary, width: 3),
                      ),
                    ),
                    child: Text(
                      '"${def.example}"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
