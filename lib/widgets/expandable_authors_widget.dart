import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExpandableAuthorsWidget extends StatefulWidget {
  final List<String> authors;
  final String uniqueKey;
  final Set<String> expandedAuthors;
  final Function(String) onToggle;
  final int threshold;
  final TextStyle? textStyle;

  const ExpandableAuthorsWidget({
    super.key,
    required this.authors,
    required this.uniqueKey,
    required this.expandedAuthors,
    required this.onToggle,
    this.threshold = 5,
    this.textStyle,
  });

  @override
  State<ExpandableAuthorsWidget> createState() => _ExpandableAuthorsWidgetState();
}

class _ExpandableAuthorsWidgetState extends State<ExpandableAuthorsWidget> {
  String get _authorsString {
    if (widget.authors.isEmpty) return 'Unknown Author';
    if (widget.authors.length == 1) return widget.authors.first;
    if (widget.authors.length == 2) return '${widget.authors.first} & ${widget.authors.last}';
    return widget.authors.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = widget.expandedAuthors.contains(widget.uniqueKey);

    if (widget.authors.length <= widget.threshold) {
      return SelectableText(
        _authorsString,
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          isExpanded
              ? _authorsString
              : '${widget.authors.take(3).join(', ')} ${l10n.andMoreAuthors(widget.authors.length - 3)}',
          style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => widget.onToggle(widget.uniqueKey),
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              isExpanded ? l10n.showLess : l10n.showAllAuthors,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }
}