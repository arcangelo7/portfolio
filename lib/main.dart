import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l10n/app_localizations.dart';
import 'widgets/publications_section.dart';
import 'widgets/theme_toggle_widget.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioTheme {
  static const Color iceWhite = Color(0xFFF0F8FF);
  static const Color emeraldGreen = Color(0xFF226C3B);
  static const Color violet = Color(0xFF420075);
  static const Color wine = Color(0xFF800020);
  static const Color cobaltBlue = Color(0xFF0000FF);
  static const Color black = Color(0xFF1A1A1A);
  static const List<Color> gold = [Color(0xFFFFD700), Color(0xFFFFA500)];

  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: cobaltBlue,
    secondary: emeraldGreen,
    tertiary: violet,
    surface: iceWhite,
    onSurface: black,
    onPrimary: iceWhite,
    onSecondary: iceWhite,
    onTertiary: iceWhite,
    error: wine,
    onError: iceWhite,
    surfaceContainerHighest: iceWhite.withValues(alpha: 0.95),
    surfaceContainer: iceWhite.withValues(alpha: 0.98),
    outline: wine.withValues(alpha: 0.2),
    onSurfaceVariant: wine.withValues(alpha: 0.7),
  );

  static final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: iceWhite,
    secondary: emeraldGreen,
    tertiary: violet,
    surface: black,
    onSurface: iceWhite,
    onPrimary: black,
    onSecondary: black,
    onTertiary: iceWhite,
    error: wine,
    onError: iceWhite,
    surfaceContainerHighest: const Color(0xFF2A2A2A),
    surfaceContainer: const Color(0xFF333333),
    outline: iceWhite.withValues(alpha: 0.2),
    onSurfaceVariant: iceWhite.withValues(alpha: 0.7),
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: iceWhite,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
  );
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.light;

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: PortfolioTheme.lightTheme,
      darkTheme: PortfolioTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: LandingPage(
        onLanguageChanged: _changeLanguage,
        currentLocale: _locale ?? const Locale('en'),
        onThemeToggle: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale currentLocale;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const LandingPage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final GlobalKey _publicationsKey = GlobalKey();
  bool _isFabExpanded = false;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _scrollToPublications() {
    final context = _publicationsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildAboutSection(context),
            _buildSkillsSection(context),
            PublicationsSection(key: _publicationsKey),
            _buildContactSection(context),
          ],
        ),
      ),
      floatingActionButton:
          isMobile
              ? _buildExpandableFab(context)
              : _buildFloatingControls(context),
      floatingActionButtonLocation:
          isMobile
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.endTop,
    );
  }

  Widget _buildFloatingControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "theme_toggle",
            shape: const CircleBorder(),
            onPressed: widget.onThemeToggle,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: ThemeToggleWidget(
              isDarkMode: widget.isDarkMode,
              onToggle: () {}, // Il toggle è gestito dall'onPressed del FAB
              size: 40.0,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "language_selector",
            shape: const CircleBorder(),
            onPressed: () => _showLanguageSelector(context),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme toggle FAB
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 40 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "theme_toggle_mobile",
                      mini: true,
                      shape: const CircleBorder(),
                      onPressed: () {
                        widget.onThemeToggle();
                        _toggleFab();
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: ThemeToggleWidget(
                        isDarkMode: widget.isDarkMode,
                        onToggle:
                            () {}, // Il toggle è gestito dall'onPressed del FAB
                        size: 32.0,
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
        if (_isFabExpanded) const SizedBox(height: 16),
        // Language selector FAB
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 40 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "language_selector_mobile",
                      mini: true,
                      shape: const CircleBorder(),
                      onPressed: () {
                        _showLanguageSelector(context);
                        _toggleFab();
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Icon(
                        Icons.language,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
        if (_isFabExpanded) const SizedBox(height: 16),
        // Main FAB
        FloatingActionButton(
          heroTag: "main_fab_mobile",
          shape: const CircleBorder(),
          onPressed: _toggleFab,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.375 : 0.0, // 135 degrees
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.settings,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇮🇹'),
                title: const Text('Italiano'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('it'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇪🇸'),
                title: const Text('Español'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullScreenProfileImage(bool isDark) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/profile_cutout.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.person,
              size: 200,
              color: PortfolioTheme.iceWhite,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors:
              isDark
                  ? [PortfolioTheme.cobaltBlue, PortfolioTheme.violet]
                  : [PortfolioTheme.cobaltBlue, PortfolioTheme.emeraldGreen],
        ),
      ),
      child: Stack(
        children: [
          // Full screen transparent PNG image
          _buildFullScreenProfileImage(isDark),

          // Text content - responsive positioning
          Positioned(
            left: isMobile ? 16 : 60,
            right: isMobile ? 16 : null,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: isMobile ? null : screenWidth * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.name,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: PortfolioTheme.iceWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 36 : 56,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                    textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.jobTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PortfolioTheme.iceWhite,
                      fontSize: isMobile ? 20 : 28,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                    textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _scrollToPublications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PortfolioTheme.iceWhite,
                        foregroundColor: PortfolioTheme.cobaltBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 30 : 40,
                          vertical: isMobile ? 16 : 20,
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.viewMyWork,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.aboutMe,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 28 : null,
            ),
            textAlign: isMobile ? TextAlign.center : null,
          ),
          const SizedBox(height: 32),
          _buildTextWithMarkdownLinks(
            context,
            AppLocalizations.of(context)!.aboutMeDescription,
            Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isMobile ? 16 : null,
            ),
            TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithMarkdownLinks(
    BuildContext context,
    String text,
    TextStyle? style,
    TextAlign textAlign,
  ) {
    final markdownRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = markdownRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: style, textAlign: textAlign);
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

    return RichText(textAlign: textAlign, text: TextSpan(children: spans));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSkillsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    final skillsCategories = {
      l10n.skillCategoryProgrammingLanguages: [
        l10n.skillPython,
        l10n.skillJavaScript,
        l10n.skillTypeScript,
        l10n.skillDart,
      ],
      l10n.skillCategoryMarkupAndTemplating: [
        l10n.skillHTML,
        l10n.skillXML,
        l10n.skillTEI,
      ],
      l10n.skillCategoryStylingAndDesign: [
        l10n.skillCSS,
        l10n.skillSASS,
        l10n.skillBootstrap,
      ],
      l10n.skillCategoryQueryAndTransform: [
        l10n.skillSPARQL,
        l10n.skillSQL,
        l10n.skillXPath,
        l10n.skillXQuery,
        l10n.skillXSLT,
      ],
      l10n.skillCategorySemanticWebAndRDF: [
        l10n.skillRDF,
        l10n.skillSPARQL,
        l10n.skillSHACL,
        l10n.skillApacheJenaFuseki,
        l10n.skillGraphDB,
        l10n.skillBlazeGraph,
        l10n.skillOpenLinkVirtuoso,
      ],
      l10n.skillCategoryFrontendLibraries: [
        l10n.skillReact,
        l10n.skillD3JS,
        l10n.skillFlutter,
      ],
      l10n.skillCategoryBackendFrameworks: [
        l10n.skillNodeJS,
        l10n.skillFlask,
        l10n.skillPrisma,
      ],
      l10n.skillCategoryDatabases: [
        l10n.skillMongoDB,
        l10n.skillPostgreSQL,
        l10n.skillRedis,
        l10n.skillApacheJenaFuseki,
        l10n.skillBlazeGraph,
        l10n.skillOpenLinkVirtuoso,
        l10n.skillGraphDB,
      ],
      l10n.skillCategoryInfrastructureDevOps: [
        l10n.skillDocker,
        l10n.skillProxmox,
        l10n.skillGitHubActions,
      ],
      l10n.skillCategoryOperatingSystems: [l10n.skillDebian, l10n.skillFedora],
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.skills,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 28 : null,
            ),
          ),
          const SizedBox(height: 32),
          _SkillsBubbleChart(
            skillsCategories: skillsCategories,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final l10n = AppLocalizations.of(context)!;

    final professionalWebsiteUrl =
        widget.currentLocale.languageCode == 'it'
            ? 'https://www.unibo.it/sitoweb/arcangelo.massari'
            : 'https://www.unibo.it/sitoweb/arcangelo.massari/en';

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Text(
            l10n.getInTouch,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 28 : null,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 16 : 24,
            runSpacing: isMobile ? 16 : 24,
            children: [
              _buildContactButton(
                context,
                Icons.email,
                l10n.email,
                'mailto:arcangelo.massari@unibo.it',
                Theme.of(context).colorScheme.tertiary,
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.web,
                l10n.professionalWebsite,
                professionalWebsiteUrl,
                Theme.of(context).colorScheme.secondary,
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.code,
                l10n.github,
                'https://github.com/arcangelo7',
                Theme.of(context).colorScheme.primary,
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.science,
                l10n.orcid,
                'https://orcid.org/0000-0002-8420-0696',
                const Color(0xFFA6CE39),
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.work,
                l10n.linkedin,
                'https://www.linkedin.com/in/arcangelo-massari-4a736822b/',
                const Color(0xFF0077B5),
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.camera_alt,
                l10n.instagram,
                'https://www.instagram.com/arcangelomassari/',
                const Color(0xFFE4405F),
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.facebook,
                l10n.facebook,
                'https://www.facebook.com/arcangelo.massari',
                const Color(0xFF1877F2),
                isMobile,
              ),
              _buildContactButton(
                context,
                Icons.alternate_email,
                l10n.twitter,
                'https://x.com/arcangelo_wd',
                const Color(0xFF000000),
                isMobile,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Text(
                l10n.copyright,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: isMobile ? 12 : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 50,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: PortfolioTheme.gold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.laoTzuQuote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: isMobile ? 10 : 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    IconData icon,
    String label,
    String url,
    Color color,
    bool isMobile,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _launchUrl(url),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: isMobile ? 24 : 28, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: isMobile ? 11 : 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SkillsBubbleChart extends StatelessWidget {
  final Map<String, List<String>> skillsCategories;
  final bool isMobile;

  const _SkillsBubbleChart({
    required this.skillsCategories,
    required this.isMobile,
  });

  // Colori distintivi per ogni categoria
  List<Color> get _categoryColors => [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5A2B), // Brown
    const Color(0xFF6B7280), // Gray
    const Color(0xFF059669), // Teal
  ];

  Color _getCategoryColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _categoryColors[index % _categoryColors.length];
    return isDark ? baseColor.withValues(alpha: 0.8) : baseColor;
  }

  Color _getDarkerCategoryColor(Color categoryColor, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(categoryColor);

    if (isDark) {
      // In dark mode, make colors lighter and more saturated for contrast
      return hsl
          .withLightness((hsl.lightness * 1.5).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation * 1.3).clamp(0.0, 1.0))
          .toColor();
    } else {
      // In light mode, create a darker, more saturated version
      return hsl
          .withLightness((hsl.lightness * 0.4).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
          .toColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Layout organico bubble-style
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 16,
              vertical: 16,
            ),
            child: _buildBubbleLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleLayout(BuildContext context) {
    final categoryEntries = skillsCategories.entries.toList();

    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: isMobile ? 12 : 16,
      alignment: WrapAlignment.center,
      children:
          categoryEntries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final categoryEntry = mapEntry.value;
            final categoryColor = _getCategoryColor(index, context);

            return _buildCategoryBubble(
              context,
              categoryEntry.key,
              categoryEntry.value,
              categoryColor,
            );
          }).toList(),
    );
  }

  Widget _buildCategoryBubble(
    BuildContext context,
    String category,
    List<String> skills,
    Color categoryColor,
  ) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 4 : 8),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.15),
            categoryColor.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titolo categoria con icona
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 8 : 10,
                height: isMobile ? 8 : 10,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: _getDarkerCategoryColor(categoryColor, context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Skills come bubble
          Wrap(
            spacing: isMobile ? 6 : 8,
            runSpacing: isMobile ? 6 : 8,
            alignment: WrapAlignment.center,
            children:
                skills
                    .map(
                      (skill) =>
                          _buildSkillBubble(context, skill, categoryColor),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBubble(
    BuildContext context,
    String skill,
    Color categoryColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }
}
