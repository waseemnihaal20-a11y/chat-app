import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/message_model.dart';
import '../utils/date_formatter.dart';
import 'avatar_widget.dart';
import 'tappable_text.dart';

/// A message bubble widget for displaying chat messages.
/// Supports sender and receiver message styles with animations.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String userName;
  final void Function(String word)? onWordLongPress;
  final VoidCallback? onRetry;
  final int index;

  const MessageBubble({
    super.key,
    required this.message,
    required this.userName,
    this.onWordLongPress,
    this.onRetry,
    this.index = 0,
  });

  bool get isSender => message.type == MessageType.sender;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    final bubbleColor = isSender
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    final textColor = isSender ? colorScheme.onPrimary : colorScheme.onSurface;

    final alignment = isSender
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isSender ? 18 : 4),
      bottomRight: Radius.circular(isSender ? 4 : 18),
    );

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Row(
                mainAxisAlignment: isSender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isSender) ...[
                    AvatarWidget(name: userName, size: 32),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: bubbleRadius,
                      ),
                      child: TappableText(
                        text: message.content,
                        onWordTap: onWordLongPress,
                        maxLines: 10,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  if (isSender) ...[
                    const SizedBox(width: 8),
                    AvatarWidget(name: 'You', size: 32),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(
                  left: isSender ? 0 : 40,
                  right: isSender ? 40 : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isSender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatMessageTime(message.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (isSender) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: isSender ? 0.1 : -0.1,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      case MessageStatus.sent:
        return FaIcon(
          FontAwesomeIcons.check,
          size: 12,
          color: colorScheme.onSurfaceVariant,
        );
      case MessageStatus.delivered:
        return FaIcon(
          FontAwesomeIcons.checkDouble,
          size: 12,
          color: colorScheme.primary,
        );
      case MessageStatus.failed:
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onRetry?.call();
          },
          child: FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 12,
            color: colorScheme.error,
          ),
        );
    }
  }
}
