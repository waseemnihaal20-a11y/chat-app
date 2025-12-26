import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text widget that allows tapping on individual words.
/// Used for the dictionary feature to look up word definitions.
class TappableText extends StatelessWidget {
  final String text;
  final void Function(String word)? onWordTap;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const TappableText({
    super.key,
    required this.text,
    this.onWordTap,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    if (onWordTap == null) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (final word in words) {
      // if (word.trim().isEmpty) {
      //   spans.add(TextSpan(text: word, style: style));
      // } else {
      spans.add(
        TextSpan(
          text: '$word ',
          style: style,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              HapticFeedback.selectionClick();
              final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
              if (cleanWord.isNotEmpty) {
                onWordTap?.call(cleanWord);
              }
            },
        ),
      );
      // }
    }

    // FIX: Add default style to root TextSpan and use DefaultTextStyle
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;

    return RichText(
      text: TextSpan(children: spans, style: defaultStyle),
      textAlign: TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
