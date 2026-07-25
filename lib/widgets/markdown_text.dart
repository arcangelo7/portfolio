// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The subset of Markdown the ARB copy actually uses: `[label](url)` links and
/// `*italic*` runs.
class MarkdownText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  State<MarkdownText> createState() => _MarkdownTextState();
}

class _MarkdownTextState extends State<MarkdownText> {
  static final RegExp _pattern = RegExp(
    r'\[([^\]]+)\]\(([^)]+)\)|\*([^*\n]+)\*',
  );

  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = _pattern.allMatches(widget.text);
    if (matches.isEmpty) {
      return SelectableText(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final style = widget.style ?? const TextStyle();
    final spans = <TextSpan>[];
    var index = 0;

    for (final match in matches) {
      if (match.start > index) {
        spans.add(
          TextSpan(
            text: widget.text.substring(index, match.start),
            style: style,
          ),
        );
      }

      final linkText = match.group(1);
      if (linkText != null) {
        final isItalic =
            linkText.length > 2 &&
            linkText.startsWith('*') &&
            linkText.endsWith('*');
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _launchUrl(match.group(2)!);
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: isItalic
                ? linkText.substring(1, linkText.length - 1)
                : linkText,
            style: style.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              fontStyle: isItalic ? FontStyle.italic : null,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: match.group(3)!,
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }

      index = match.end;
    }

    if (index < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(index), style: style));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: widget.textAlign,
    );
  }
}
