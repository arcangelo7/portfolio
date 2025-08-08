import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_flags/country_flags.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'widgets/publications_section.dart';
import 'widgets/work_experience_section.dart';
import 'widgets/education_section.dart';
import 'widgets/conferences_seminars_section.dart';
import 'widgets/astrogods_section.dart';
import 'widgets/theme_toggle_widget.dart';
import 'widgets/orbiting_planets_widget.dart';
import 'widgets/table_of_contents_widget.dart';
import 'widgets/flutter_modal.dart';
import 'widgets/faq_section.dart';
import 'widgets/lazy_image.dart';
import 'services/dynamic_cv_generator_service.dart';
import 'services/zotero_service.dart';
import 'services/seo_service.dart';
import 'utils/web_utils.dart';
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize window_manager on desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const PortfolioApp());
}

class PortfolioTheme {
  static const Color iceWhite = Color(0xFFF0F8FF);
  static const Color emeraldGreen = Color(0xFF226C3B);
  static const Color violet = Color(0xFF420075);
  static const Color wine = Color(0xFF800020);
  static const Color cobaltBlue = Color(0xFF000075);
  static const Color black = Color(0xFF1A1A1A);
  static const List<Color> gold = [Color(0xFFFFD700), Color(0xFFFFA500)];

  // AstroGods section colors
  static const Color astroMysticBlue = Color(0xFF1A1A2E);
  static const Color astroDarkViolet = Color(0xFF16213E);
  static const Color astroDeepBlue = Color(0xFF0F3460);
  static const Color astroGold = Color(0xFFFFD700);
  static const Color astroLightGray = Color(0xFFE0E0E0);
  static const Color astroProblemRed = Color(0xFFE74C3C);
  static const Color astroElementViolet = Color(0xFF9B59B6);
  static const Color astroComplexityOrange = Color(0xFFE67E22);
  static const Color astroTraditionBlue = Color(0xFF3498DB);
  static const Color astroAiGreen = Color(0xFF2ECC71);

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
  GlobalKey<_LandingPageState>? _landingPageKey;

  @override
  void initState() {
    super.initState();
    _landingPageKey = GlobalKey<_LandingPageState>();
    if (kIsWeb) {
      _initializeLanguageFromUrl();
    }
  }

  void _initializeLanguageFromUrl() {
    if (!kIsWeb) {
      // Default to English on non-web platforms
      setState(() {
        _locale = const Locale('en');
      });
      return;
    }

    try {
      final langParam = WebUtils.getLanguageFromUrl();
      final fragment = WebUtils.getFragmentFromUrl();

      if (['en', 'it', 'es'].contains(langParam)) {
        setState(() {
          _locale = Locale(langParam);
        });
      } else {
        // Default to English if no valid lang parameter
        setState(() {
          _locale = const Locale('en');
        });
        _updateUrlWithLanguage('en', replaceState: true);
      }

      // Handle fragment (anchor) navigation after the widget is built
      if (fragment.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add a small delay to ensure all widgets are rendered
          Future.delayed(const Duration(milliseconds: 500), () {
            _navigateToSection(fragment);
          });
        });
      }
    } catch (e) {
      // Fallback to English on any error
      setState(() {
        _locale = const Locale('en');
      });
    }
  }

  void _navigateToSection(String sectionId) {
    // Call the landing page to scroll to the section
    _landingPageKey?.currentState?.scrollToSectionById(sectionId);
  }

  void _updateUrlWithLanguage(
    String languageCode, {
    bool replaceState = false,
  }) {
    if (kIsWeb) {
      try {
        final currentUrl = WebUtils.getCurrentUrl();
        final uri = Uri.parse(currentUrl);
        final newUri = uri.replace(queryParameters: {'lang': languageCode});
        WebUtils.updateUrl(newUri.toString(), replaceState: replaceState);
      } catch (e) {
        debugPrint('Error updating URL: $e');
      }
    }
  }

  void updateUrlWithSection(String section) {
    if (kIsWeb) {
      try {
        final currentLang = _locale?.languageCode ?? 'en';
        WebUtils.updateUrlWithLanguageAndSection(currentLang, section);
      } catch (e) {
        debugPrint('Error updating URL with section: $e');
      }
    }
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _updateUrlWithLanguage(locale.languageCode);
    _updateWindowTitle();

    // Update SEO meta tags when language changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          SEOService.updateMetaTags(l10n, locale.languageCode);
        }
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _updateWindowTitle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        final title = AppLocalizations.of(context)!.appTitle;
        windowManager.setTitle(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) {
        final title = AppLocalizations.of(context)!.appTitle;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS)) {
            windowManager.setTitle(title);
          }
          // Update SEO meta tags when app starts or title is generated
          final l10n = AppLocalizations.of(context);
          if (l10n != null && kIsWeb) {
            SEOService.updateMetaTags(l10n, _locale?.languageCode ?? 'en');
          }
        });
        return title;
      },
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
        key: _landingPageKey,
        onLanguageChanged: _changeLanguage,
        currentLocale: _locale ?? const Locale('en'),
        onThemeToggle: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
        onSectionChanged: updateUrlWithSection,
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale currentLocale;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final Function(String) onSectionChanged;

  const LandingPage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onSectionChanged,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _workKey = GlobalKey();
  final GlobalKey _educationKey = GlobalKey();
  final GlobalKey _conferencesKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _publicationsKey = GlobalKey();
  final GlobalKey _astrogodsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  bool _isFabExpanded = false;
  bool _isTocVisible = false;
  bool _isDownloadingCV = false;

  late AnimationController _fabAnimationController;
  late AnimationController _tocAnimationController;

  bool _isInTestEnvironment() {
    return WidgetsBinding.instance.runtimeType.toString() ==
        'TestWidgetsFlutterBinding';
  }

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tocAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _tocAnimationController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionName, GlobalKey sectionKey) {
    final context = sectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      widget.onSectionChanged(sectionName);
    }
  }

  void scrollToSectionById(String sectionId) {
    final sectionKey = _sectionKeys[sectionId];
    if (sectionKey != null) {
      _scrollToSection(sectionId, sectionKey);
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

  void _toggleToc() {
    setState(() {
      _isTocVisible = !_isTocVisible;
      if (_isTocVisible) {
        _tocAnimationController.forward();
      } else {
        _tocAnimationController.reverse();
      }
    });
  }

  Map<String, GlobalKey> get _sectionKeys => {
    'about': _aboutKey,
    'work': _workKey,
    'education': _educationKey,
    'conferences': _conferencesKey,
    'skills': _skillsKey,
    'publications': _publicationsKey,
    'astrogods': _astrogodsKey,
    'faq': _faqKey,
    'contact': _contactKey,
  };

  Future<void> _downloadCV() async {
    if (_isDownloadingCV) return;

    setState(() {
      _isDownloadingCV = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final zoteroService = ZoteroService();

      final pdfBytes = await DynamicCVGeneratorService.generateCV(
        l10n,
        zoteroService: zoteroService,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'CV_Arcangelo_Massari_${widget.currentLocale.languageCode}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cvGeneratedSuccessfully),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating CV: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingCV = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (!isMobile && isDesktop) _buildCustomTitleBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroSection(context),
                      _buildAboutSection(context, key: _aboutKey),
                      WorkExperienceSection(key: _workKey),
                      EducationSection(key: _educationKey),
                      ConferencesSeminarsSection(key: _conferencesKey),
                      _buildSkillsSection(context, key: _skillsKey),
                      PublicationsSection(key: _publicationsKey),
                      AstroGodsSection(key: _astrogodsKey),
                      FAQSection(sectionKey: _faqKey),
                      _buildContactSection(context, key: _contactKey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isTocVisible) _buildTocOverlay(context),
        ],
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

  Widget _buildCustomTitleBar(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.macOS)) {
          windowManager.startDragging();
        }
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors:
                Theme.of(context).brightness == Brightness.dark
                    ? [PortfolioTheme.cobaltBlue, PortfolioTheme.violet]
                    : [PortfolioTheme.cobaltBlue, PortfolioTheme.emeraldGreen],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(
                    color: PortfolioTheme.iceWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleBarButton(Icons.minimize, () {
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.macOS)) {
                    windowManager.minimize();
                  }
                }),
                _buildTitleBarButton(Icons.crop_square, () async {
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.macOS)) {
                    if (await windowManager.isMaximized()) {
                      windowManager.unmaximize();
                    } else {
                      windowManager.maximize();
                    }
                  }
                }),
                _buildTitleBarButton(Icons.close, () {
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.macOS)) {
                    windowManager.close();
                  }
                }, isClose: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBarButton(
    IconData icon,
    VoidCallback onPressed, {
    bool isClose = false,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor:
              isClose
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
          child: Icon(icon, size: 14, color: PortfolioTheme.iceWhite),
        ),
      ),
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
            tooltip:
                widget.isDarkMode
                    ? AppLocalizations.of(context)!.lightModeIconAlt
                    : AppLocalizations.of(context)!.darkModeIconAlt,
            child: Semantics(
              button: true,
              label:
                  widget.isDarkMode
                      ? AppLocalizations.of(context)!.lightModeIconAlt
                      : AppLocalizations.of(context)!.darkModeIconAlt,
              child: ThemeToggleWidget(
                isDarkMode: widget.isDarkMode,
                onToggle: () {},
                size: 40.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "language_selector",
            shape: const CircleBorder(),
            onPressed: () => _showLanguageSelector(context),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            tooltip: AppLocalizations.of(context)!.selectLanguage,
            child: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSecondary,
              size: 32.0,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "download_cv",
            shape: const CircleBorder(),
            onPressed: _isDownloadingCV ? null : _downloadCV,
            backgroundColor: Theme.of(context).colorScheme.error,
            tooltip:
                _isDownloadingCV
                    ? AppLocalizations.of(context)!.downloadingCV
                    : AppLocalizations.of(context)!.downloadCV,
            child:
                _isDownloadingCV
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    )
                    : Icon(
                      Icons.download_rounded,
                      color: Theme.of(context).colorScheme.onError,
                      size: 32.0,
                    ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "table_of_contents",
            shape: const CircleBorder(),
            onPressed: _toggleToc,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            tooltip: AppLocalizations.of(context)!.tableOfContents,
            child: AnimatedRotation(
              turns: _isTocVisible ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isTocVisible ? Icons.close : Icons.list_rounded,
                color: Theme.of(context).colorScheme.onTertiary,
                size: 32.0,
              ),
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
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "theme_toggle_mobile",
                      shape: const CircleBorder(),
                      onPressed: () {
                        widget.onThemeToggle();
                        _toggleFab();
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      tooltip:
                          widget.isDarkMode
                              ? AppLocalizations.of(context)!.lightModeIconAlt
                              : AppLocalizations.of(context)!.darkModeIconAlt,
                      child: Semantics(
                        button: true,
                        label:
                            widget.isDarkMode
                                ? AppLocalizations.of(context)!.lightModeIconAlt
                                : AppLocalizations.of(context)!.darkModeIconAlt,
                        child: ThemeToggleWidget(
                          isDarkMode: widget.isDarkMode,
                          onToggle: () {},
                          size: 24.0,
                        ),
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
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "language_selector_mobile",
                      shape: const CircleBorder(),
                      onPressed: () {
                        _showLanguageSelector(context);
                        _toggleFab();
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      tooltip: AppLocalizations.of(context)!.selectLanguage,
                      child: Icon(
                        Icons.language,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 24.0,
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
        if (_isFabExpanded) const SizedBox(height: 16),
        // Download CV FAB
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "download_cv_mobile",
                      shape: const CircleBorder(),
                      onPressed:
                          _isDownloadingCV
                              ? null
                              : () {
                                _downloadCV();
                                _toggleFab();
                              },
                      backgroundColor: Theme.of(context).colorScheme.error,
                      tooltip:
                          _isDownloadingCV
                              ? AppLocalizations.of(context)!.downloadingCV
                              : AppLocalizations.of(context)!.downloadCV,
                      child:
                          _isDownloadingCV
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onError,
                                ),
                              )
                              : Icon(
                                Icons.download_rounded,
                                color: Theme.of(context).colorScheme.onError,
                                size: 24.0,
                              ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
        if (_isFabExpanded) const SizedBox(height: 16),
        // TOC FAB
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child:
                _isFabExpanded
                    ? FloatingActionButton(
                      heroTag: "table_of_contents_mobile",
                      shape: const CircleBorder(),
                      onPressed: () {
                        _toggleToc();
                        _toggleFab();
                      },
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      tooltip: AppLocalizations.of(context)!.tableOfContents,
                      child: AnimatedRotation(
                        turns: _isTocVisible ? 0.125 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isTocVisible ? Icons.close : Icons.list_rounded,
                          color: Theme.of(context).colorScheme.onTertiary,
                          size: 24.0,
                        ),
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
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTocOverlay(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GestureDetector(
      onTap: _toggleToc,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isTocVisible ? 1.0 : 0.0,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on the TOC itself
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                child: TableOfContentsWidget(
                  sectionKeys: _sectionKeys,
                  onTap: _toggleToc,
                  onSectionChanged: widget.onSectionChanged,
                ),
              ),
            ),
          ),
        ),
      ),
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
                AppLocalizations.of(context)!.selectLanguage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Semantics(
                button: true,
                label: 'Change language to English',
                child: ListTile(
                  leading: CountryFlag.fromCountryCode(
                    'US',
                    width: 20,
                    height: 15,
                  ),
                  title: const Text('English'),
                  onTap: () {
                    widget.onLanguageChanged(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ),
              Semantics(
                button: true,
                label: 'Cambia lingua in Italiano',
                child: ListTile(
                  leading: CountryFlag.fromCountryCode(
                    'IT',
                    width: 20,
                    height: 15,
                  ),
                  title: const Text('Italiano'),
                  onTap: () {
                    widget.onLanguageChanged(const Locale('it'));
                    Navigator.pop(context);
                  },
                ),
              ),
              Semantics(
                button: true,
                label: 'Cambiar idioma a Español',
                child: ListTile(
                  leading: CountryFlag.fromCountryCode(
                    'ES',
                    width: 20,
                    height: 15,
                  ),
                  title: const Text('Español'),
                  onTap: () {
                    widget.onLanguageChanged(const Locale('es'));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullScreenProfileImage(bool isDark) {
    return Positioned.fill(
      child: LazyImage(
        assetPath: 'assets/images/profile_cutout.png',
        fit: BoxFit.cover,
        critical: true, // This is above the fold, load immediately
        semanticLabel: AppLocalizations.of(context)?.profileImageAlt,
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
          // Static sun/moon element in top-left
          StaticThemeElementsWidget(
            isDarkMode: isDark,
            elementSize: isMobile ? 120.0 : 180.0,
            enableAnimation: !_isInTestEnvironment(),
          ),

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
                  Semantics(
                    header: true,
                    child: SelectableText(
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
                      semanticsLabel:
                          'Main heading: ${AppLocalizations.of(context)!.name}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
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
                  ElevatedButton(
                    onPressed: () {
                      scrollToSectionById('publications');
                    },
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, {required GlobalKey key}) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      key: key,
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              AppLocalizations.of(context)!.aboutMe,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              textAlign: isMobile ? TextAlign.center : null,
              semanticsLabel:
                  'Section heading: ${AppLocalizations.of(context)!.aboutMe}',
            ),
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
      return SelectableText(text, style: style, textAlign: textAlign);
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

    return SelectableText.rich(TextSpan(children: spans), textAlign: textAlign);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSkillsSection(BuildContext context, {required GlobalKey key}) {
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
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              AppLocalizations.of(context)!.skills,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel:
                  'Section heading: ${AppLocalizations.of(context)!.skills}',
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

  Widget _buildContactSection(BuildContext context, {required GlobalKey key}) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final l10n = AppLocalizations.of(context)!;

    final professionalWebsiteUrl =
        widget.currentLocale.languageCode == 'it'
            ? 'https://www.unibo.it/sitoweb/arcangelo.massari'
            : 'https://www.unibo.it/sitoweb/arcangelo.massari/en';

    return Container(
      key: key,
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.getInTouch,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.getInTouch}',
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  isMobile
                      ? MediaQuery.of(context).size.width - 130
                      : double.infinity,
            ),
            child: Column(
              children: [
                SelectableText(
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
                SelectableText(
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
        SelectableText(
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

  // Colori distintivi per ogni categoria (ordinati secondo la scala cromatica)
  List<Color> get _categoryColors => [
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF10B981), // Green/Emerald
    const Color(0xFF059669), // Teal (verde-azzurro)
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF6366F1), // Blue/Indigo
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink/Magenta
    const Color(0xFF6B7280), // Gray (neutro)
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
                child: SelectableText(
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
    final l10n = AppLocalizations.of(context)!;
    final isFlutter = skill == l10n.skillFlutter;

    if (isFlutter) {
      return _buildFlutterSkillBubble(context, skill);
    }

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
      child: SelectableText(
        skill,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildFlutterSkillBubble(BuildContext context, String skill) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _showFlutterModal(context),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 18,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PortfolioTheme.cobaltBlue,
                PortfolioTheme.cobaltBlue.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: PortfolioTheme.cobaltBlue.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: PortfolioTheme.cobaltBlue.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flutter_dash,
                color: Colors.white,
                size: isMobile ? 16 : 18,
              ),
              const SizedBox(width: 6),
              SelectableText(
                skill,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.open_in_new,
                color: Colors.white.withValues(alpha: 0.8),
                size: isMobile ? 12 : 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFlutterModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const FlutterModal(),
    );
  }
}
