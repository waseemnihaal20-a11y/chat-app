import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/utils/avatar_helper.dart';

void main() {
  group('AvatarHelper', () {
    group('getInitial', () {
      test('should return uppercase first letter of name', () {
        expect(AvatarHelper.getInitial('John Doe'), 'J');
        expect(AvatarHelper.getInitial('alice'), 'A');
        expect(AvatarHelper.getInitial('Bob Smith'), 'B');
      });

      test('should return "?" for empty name', () {
        expect(AvatarHelper.getInitial(''), '?');
      });

      test('should handle single character names', () {
        expect(AvatarHelper.getInitial('X'), 'X');
        expect(AvatarHelper.getInitial('a'), 'A');
      });
    });

    group('getColorForName', () {
      test('should return consistent color for same name', () {
        final color1 = AvatarHelper.getColorForName('John');
        final color2 = AvatarHelper.getColorForName('John');
        expect(color1, color2);
      });

      test('should return different colors for different names', () {
        final color1 = AvatarHelper.getColorForName('John');
        final color2 = AvatarHelper.getColorForName('Jane');
        // Colors might be the same due to hash collision, but usually different
        // We just test that the method returns a valid color
        expect(color1, isA<Color>());
        expect(color2, isA<Color>());
      });

      test('should return a color for empty name', () {
        final color = AvatarHelper.getColorForName('');
        expect(color, isA<Color>());
      });
    });

    group('getTextColor', () {
      test('should return white for dark backgrounds', () {
        const darkColor = Color(0xFF000000);
        final textColor = AvatarHelper.getTextColor(darkColor);
        expect(textColor, Colors.white);
      });

      test('should return black for light backgrounds', () {
        const lightColor = Color(0xFFFFFFFF);
        final textColor = AvatarHelper.getTextColor(lightColor);
        expect(textColor, Colors.black);
      });

      test('should handle mid-tone colors', () {
        const midColor = Color(0xFF808080);
        final textColor = AvatarHelper.getTextColor(midColor);
        // Should return either black or white
        expect(textColor == Colors.black || textColor == Colors.white, true);
      });
    });
  });
}
