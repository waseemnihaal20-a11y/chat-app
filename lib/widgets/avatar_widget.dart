import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/avatar_helper.dart';

/// A circular avatar widget that displays a user's initial.
/// Uses consistent colors based on the user's name.
class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final double? fontSize;
  final bool animate;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.fontSize,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AvatarHelper.getColorForName(name);
    final textColor = AvatarHelper.getTextColor(backgroundColor);
    final initial = AvatarHelper.getInitial(name);
    final effectiveFontSize = fontSize ?? size * 0.4;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: textColor,
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (animate) {
      avatar = avatar.animate().scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
      );
    }

    return avatar;
  }
}
