import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/seo_service.dart';

class FAQSection extends StatefulWidget {
  final GlobalKey? sectionKey;

  const FAQSection({super.key, this.sectionKey});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection>
    with TickerProviderStateMixin {
  final List<bool> _isExpanded = [];
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = [];
  }

  void _initializeAnimations() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final faqs = _getFAQs(l10n);
    
    // Only initialize if not already initialized or if count changed
    if (_animationControllers.isEmpty || _animationControllers.length != faqs.length) {
      // Dispose existing controllers
      for (final controller in _animationControllers) {
        controller.dispose();
      }
      
      _isExpanded.clear();
      _animationControllers = [];
      
      for (int i = 0; i < faqs.length; i++) {
        _isExpanded.add(false);
        _animationControllers.add(
          AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeAnimations();
    _updateStructuredData();
  }

  void _updateStructuredData() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    final faqs = _getFAQs(l10n);
    SEOService.addFAQStructuredData(faqs, l10n);
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Map<String, String>> _getFAQs(AppLocalizations l10n) {
    return [
      {
        'question': l10n.faqResearchQuestion,
        'answer': l10n.faqResearchAnswer,
      },
      {
        'question': l10n.faqTechnicalQuestion,
        'answer': l10n.faqTechnicalAnswer,
      },
      {
        'question': l10n.faqContactQuestion,
        'answer': l10n.faqContactAnswer,
      },
    ];
  }

  void _toggleFAQ(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
      if (_isExpanded[index]) {
        _animationControllers[index].forward();
      } else {
        _animationControllers[index].reverse();
      }
    });
  }

  Widget _buildTextWithMarkdownLinks(
    BuildContext context,
    String text,
    TextStyle? style,
  ) {
    final markdownRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = markdownRegex.allMatches(text);
    
    if (matches.isEmpty) {
      return SelectableText(text, style: style);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;
    
    for (final match in matches) {
      // Add text before the link
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }
      
      // Add the clickable link
      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;
      spans.add(
        TextSpan(
          text: linkText,
          style: style?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(linkUrl),
        ),
      );
      currentIndex = match.end;
    }
    
    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }
    
    return SelectableText.rich(TextSpan(children: spans));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 768;
    final faqs = _getFAQs(l10n);

    return Container(
      key: widget.sectionKey,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.frequentlyAskedQuestions,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              textAlign: isMobile ? TextAlign.center : null,
              semanticsLabel: 'Section heading: ${l10n.frequentlyAskedQuestions}',
            ),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildFAQItem(
              context,
              faqs[index],
              index,
              isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    Map<String, String> faq,
    int index,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleFAQ(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq['question'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: isMobile ? 16 : 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedRotation(
                      turns: _isExpanded[index] ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.primary,
                        size: isMobile ? 24 : 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animationControllers[index],
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 20,
                0,
                isMobile ? 16 : 20,
                isMobile ? 16 : 20,
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildTextWithMarkdownLinks(
                  context,
                  faq['answer'] ?? '',
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isMobile ? 14 : 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}