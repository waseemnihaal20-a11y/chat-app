import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated typing indicator widget showing 3 bouncing dots.
class TypingIndicator extends StatelessWidget {
  final Color? color;
  final double dotSize;

  const TypingIndicator({super.key, this.color, this.dotSize = 8});

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(dotColor, 0),
        SizedBox(width: dotSize * 0.5),
        _buildDot(dotColor, 1),
        SizedBox(width: dotSize * 0.5),
        _buildDot(dotColor, 2),
      ],
    );
  }

  Widget _buildDot(Color color, int index) {
    return Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .slideY(
          begin: 0,
          end: -0.5,
          duration: 400.ms,
          delay: (index * 150).ms,
          curve: Curves.easeInOut,
        )
        .then()
        .slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }
}

/// Typing indicator bubble that looks like a message
class TypingBubble extends StatelessWidget {
  final String userName;

  const TypingBubble({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const TypingIndicator(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, duration: 200.ms);
  }
}
