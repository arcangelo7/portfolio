import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class TableOfContentsWidget extends StatefulWidget {
  final Map<String, GlobalKey> sectionKeys;
  final VoidCallback? onTap;
  final Function(String)? onSectionChanged;

  const TableOfContentsWidget({
    super.key,
    required this.sectionKeys,
    this.onTap,
    this.onSectionChanged,
  });

  @override
  State<TableOfContentsWidget> createState() => _TableOfContentsWidgetState();
}

class _TableOfContentsWidgetState extends State<TableOfContentsWidget>
    with TickerProviderStateMixin {
  String? _activeSectionKey;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Widget _buildStrikethroughText(
    String text,
    TextStyle? style,
    BuildContext context,
  ) {
    final strikethroughRegex = RegExp(r'~~([^~]+)~~');
    final match = strikethroughRegex.firstMatch(text);

    if (match == null) {
      return Text(text, style: style);
    }

    final beforeText = text.substring(0, match.start);
    final strikethroughText = match.group(1)!;
    final afterText = text.substring(match.end);

    final defaultColor = Theme.of(context).colorScheme.primary;
    final textColor = style?.color ?? defaultColor;

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          if (beforeText.isNotEmpty) TextSpan(text: beforeText),
          TextSpan(
            text: strikethroughText,
            style: style?.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: textColor,
              decorationThickness: 2.0,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          if (afterText.isNotEmpty) TextSpan(text: afterText),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionKey) {
    final key = widget.sectionKeys[sectionKey];
    if (key?.currentContext != null) {
      HapticFeedback.lightImpact();

      setState(() {
        _activeSectionKey = sectionKey;
      });

      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ).then((_) {
        if (widget.onSectionChanged != null) {
          widget.onSectionChanged!(sectionKey);
        }
        if (widget.onTap != null) {
          widget.onTap!();
        }
      });
    }
  }

  List<Map<String, dynamic>> _getSections(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'about', 'title': l10n.aboutMe, 'icon': Icons.person},
      {'key': 'work', 'title': l10n.workExperience, 'icon': Icons.work},
      {'key': 'education', 'title': l10n.education, 'icon': Icons.school},
      {
        'key': 'conferences',
        'title': l10n.conferencesAndSeminars,
        'icon': Icons.mic,
      },
      {'key': 'skills', 'title': l10n.skills, 'icon': Icons.build},
      {'key': 'publications', 'title': l10n.publications, 'icon': Icons.article},
      {'key': 'astrogods', 'title': l10n.astroGodsTitle, 'icon': Icons.travel_explore},
      {'key': 'faq', 'title': l10n.frequentlyAskedQuestions, 'icon': Icons.help_outline},
      {'key': 'contact', 'title': l10n.getInTouch, 'icon': Icons.email},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _getSections(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? 250 : 280),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.list_rounded,
                    size: isMobile ? 20 : 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.tableOfContents,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: isMobile ? 16 : 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              itemCount: sections.length,
              separatorBuilder:
                  (context, index) => SizedBox(height: isMobile ? 4 : 6),
              itemBuilder: (context, index) {
                final section = sections[index];
                final isActive = _activeSectionKey == section['key'];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isActive
                            ? Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            )
                            : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _scrollToSection(section['key']!),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              section['icon'] as IconData,
                              size: isMobile ? 16 : 18,
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStrikethroughText(
                                section['title']!,
                                Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight:
                                      isActive
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  color:
                                      isActive
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  fontSize: isMobile ? 14 : 15,
                                ),
                                context,
                              ),
                            ),
                            if (isActive)
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: isMobile ? 12 : 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
