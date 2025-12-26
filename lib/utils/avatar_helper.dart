import 'package:flutter/material.dart';

/// Utility class for avatar-related helpers.
class AvatarHelper {
  AvatarHelper._();

  /// List of colors for avatar backgrounds
  static const List<Color> _avatarColors = [
    Color(0xFF1ABC9C), // Turquoise
    Color(0xFF2ECC71), // Emerald
    Color(0xFF3498DB), // Peter River
    Color(0xFF9B59B6), // Amethyst
    Color(0xFFE74C3C), // Alizarin
    Color(0xFFF39C12), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF795548), // Brown
  ];

  /// Gets the initial letter from a name for avatar display.
  /// Returns uppercase first character or '?' if empty.
  static String getInitial(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  /// Gets a consistent color for an avatar based on the name.
  /// Uses the name's hashCode to select a color from the palette.
  static Color getColorForName(String name) {
    if (name.isEmpty) return _avatarColors[0];
    final index = name.hashCode.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

  /// Gets a contrasting text color (white or black) for a given background.
  static Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
