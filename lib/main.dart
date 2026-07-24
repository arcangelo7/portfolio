// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:printing/printing.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:window_manager/window_manager.dart';

import 'controllers/publications_controller.dart';
import 'l10n/app_localizations.dart';
import 'models/cv_data.dart';
import 'models/language_data.dart';
import 'services/cv_data_service.dart';
import 'services/dynamic_cv_generator_service.dart';
import 'services/europass_cv_generator_service.dart';
import 'services/seo_service.dart';
import 'services/zotero_service.dart';
import 'utils/responsive.dart';
import 'utils/web_utils.dart';
import 'widgets/about_section.dart';
import 'widgets/astrogods_section.dart';
import 'widgets/conferences_seminars_section.dart';
import 'widgets/contact_section.dart';
import 'widgets/education_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/language_selector_sheet.dart';
import 'widgets/languages_section.dart';
import 'widgets/publications_section.dart';
import 'widgets/skills_section.dart';
import 'widgets/table_of_contents_widget.dart';
import 'widgets/theme_toggle_widget.dart';
import 'widgets/work_experience_section.dart';

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
  static const Color lightCobaltBlue = Color(0xFF8E8EF0);
  static const Color black = Color(0xFF1A1A1A);

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
    primary: lightCobaltBlue,
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

  // Typography: Felipa (calligraphic script, single weight 400 — never bold)
  // only for display roles (hero name and section titles), IBM Plex Sans
  // for everything else, IBM Plex Mono for labels/metadata.
  static const String fontDisplay = 'Felipa';
  static const String fontBody = 'IBMPlexSans';
  static const String fontMono = 'IBMPlexMono';

  static TextTheme _buildTextTheme(TextTheme base) {
    TextStyle? serif(TextStyle? style) =>
        style?.copyWith(fontFamily: fontDisplay);
    TextStyle? sans(TextStyle? style) => style?.copyWith(fontFamily: fontBody);
    TextStyle? mono(TextStyle? style) => style?.copyWith(fontFamily: fontMono);
    return base.copyWith(
      displayLarge: serif(base.displayLarge),
      displayMedium: serif(base.displayMedium),
      displaySmall: serif(base.displaySmall),
      headlineLarge: sans(base.headlineLarge),
      headlineMedium: sans(base.headlineMedium),
      headlineSmall: sans(base.headlineSmall),
      titleLarge: sans(base.titleLarge),
      titleMedium: sans(base.titleMedium),
      titleSmall: sans(base.titleSmall),
      bodyLarge: sans(base.bodyLarge),
      bodyMedium: sans(base.bodyMedium),
      bodySmall: sans(base.bodySmall),
      labelLarge: mono(base.labelLarge),
      labelMedium: mono(base.labelMedium),
      labelSmall: mono(base.labelSmall),
    );
  }

  static ThemeData lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: iceWhite,
    fontFamily: fontBody,
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    fontFamily: fontBody,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
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
  String? _initialSectionId;

  @override
  void initState() {
    super.initState();
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

      if (fragment.isNotEmpty) {
        _initialSectionId = fragment;
      }
    } catch (e) {
      // Fallback to English on any error
      setState(() {
        _locale = const Locale('en');
      });
    }
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
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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
        onLanguageChanged: _changeLanguage,
        currentLocale: _locale ?? const Locale('en'),
        onThemeToggle: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
        onSectionChanged: updateUrlWithSection,
        initialSectionId: _initialSectionId,
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  final ValueChanged<Locale> onLanguageChanged;
  final Locale currentLocale;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final ValueChanged<String> onSectionChanged;
  final String? initialSectionId;
  final PublicationsController? publicationsController;

  const LandingPage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onSectionChanged,
    this.initialSectionId,
    this.publicationsController,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static const int _publicationChunkStartIndex = 7;
  static const int _astroGodsIndex =
      _publicationChunkStartIndex + PublicationsSection.chunkCount;
  static const int _contactIndex = _astroGodsIndex + 1;
  static const Map<String, int> _sectionIndices = {
    'hero': 0,
    'about': 1,
    'work': 2,
    'education': 3,
    'conferences': 4,
    'skills': 5,
    'languages': 6,
    'publications': 7,
    'astrogods': _astroGodsIndex,
    'contact': _contactIndex,
  };
  static const int _itemCount = _contactIndex + 1;

  bool _isFabExpanded = false;
  bool _isTocVisible = false;
  bool _isDownloadingCV = false;
  bool _isDownloadingEuropassCV = false;
  bool _isInitialSectionPositioned = true;
  Set<int> _visibleSectionIndices = {0};

  late final AnimationController _fabAnimationController;
  late final ScrollController _scrollController;
  late final ListObserverController _listObserverController;
  late final Future<void> _sectionDataReady;
  late final PublicationsController _publicationsController;
  late final bool _ownsPublicationsController;
  CVData? _cvData;
  LanguageData? _languageData;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController = ScrollController();
    _listObserverController = ListObserverController(
      controller: _scrollController,
    )..cacheJumpIndexOffset = false;
    _sectionDataReady = _loadSectionData();
    final initialIndex = _sectionIndices[widget.initialSectionId];
    if (initialIndex != null) {
      _isInitialSectionPositioned = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_positionInitialSection(initialIndex));
      });
    }
    _ownsPublicationsController = widget.publicationsController == null;
    _publicationsController =
        widget.publicationsController ?? PublicationsController();
    unawaited(_publicationsController.loadPublications());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    if (_ownsPublicationsController) {
      _publicationsController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSectionData() async {
    final cvDataFuture = CVDataService.loadCVData();
    final languageDataFuture = CVDataService.getLanguages();
    final cvData = await cvDataFuture;
    final languageData = await languageDataFuture;
    if (mounted) {
      setState(() {
        _cvData = cvData;
        _languageData = languageData;
      });
    }
  }

  Future<void> scrollToSectionById(String sectionId) async {
    final index = _sectionIndices[sectionId];
    if (index == null) {
      return;
    }
    await _prepareSectionNavigation(index);
    if (!mounted) {
      return;
    }
    await WidgetsBinding.instance.endOfFrame;
    await _listObserverController.animateTo(
      index: index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    if (mounted) {
      widget.onSectionChanged(sectionId);
    }
  }

  Future<void> _positionInitialSection(int index) async {
    await _prepareSectionNavigation(index);
    if (!mounted) {
      return;
    }
    await WidgetsBinding.instance.endOfFrame;
    await _listObserverController.jumpTo(index: index);
    if (mounted) {
      setState(() {
        _isInitialSectionPositioned = true;
      });
    }
  }

  Future<void> _prepareSectionNavigation(int index) async {
    await Future.wait([
      _sectionDataReady,
      if (index >= _astroGodsIndex) _publicationsController.prepareLayout(),
    ]);
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
    });
  }

  Future<void> _downloadCV() async {
    if (_isDownloadingCV) return;

    setState(() {
      _isDownloadingCV = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
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
            content: Text(l10n.cvGenerationError(e.toString())),
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

  Future<void> _downloadEuropassCV() async {
    if (_isDownloadingEuropassCV) return;

    setState(() {
      _isDownloadingEuropassCV = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final pdfBytes = await EuropassCVGeneratorService.generateEuropassCV(
        l10n,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'CV_Europass_Arcangelo_Massari_${widget.currentLocale.languageCode}.pdf',
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
            content: Text(l10n.europassCvGenerationError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingEuropassCV = false;
        });
      }
    }
  }

  Future<void> _showCVDownloadDialog() async {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cvDownloadDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  l10n.cvDownloadMyWay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _downloadCV();
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  l10n.cvDownloadOfficeWay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _downloadEuropassCV();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
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
                child: IgnorePointer(
                  ignoring: !_isInitialSectionPositioned,
                  child: Opacity(
                    opacity: _isInitialSectionPositioned ? 1 : 0,
                    child: ListViewObserver(
                      controller: _listObserverController,
                      onObserve: (result) {
                        final visibleIndices = result.displayingChildIndexList
                            .toSet();
                        if (visibleIndices.isNotEmpty) {
                          _visibleSectionIndices = visibleIndices;
                        }
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollCacheExtent: ScrollCacheExtent.pixels(
                          Responsive.sizeOf(context).height,
                        ),
                        itemCount: _itemCount,
                        itemBuilder: (context, index) {
                          final sectionId = _sectionIdAt(index);
                          return IndexedSemantics(
                            index: index,
                            child: KeyedSubtree(
                              key: ValueKey(
                                sectionId == null
                                    ? 'publications-chunk-$index'
                                    : 'section-$sectionId',
                              ),
                              child: _buildItem(
                                index,
                                sectionId: sectionId,
                                animateTheme: _visibleSectionIndices.contains(
                                  index,
                                ),
                              ),
                            ),
                          );
                        },
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        addSemanticIndexes: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isTocVisible) _buildTocOverlay(context),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => isMobile
            ? _buildExpandableFab(context)
            : _buildFloatingControls(context),
      ),
      floatingActionButtonLocation: isMobile
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
    );
  }

  String? _sectionIdAt(int index) {
    for (final entry in _sectionIndices.entries) {
      if (entry.value == index) {
        return entry.key;
      }
    }
    return null;
  }

  Widget _buildItem(
    int index, {
    required String? sectionId,
    required bool animateTheme,
  }) {
    if (index >= _publicationChunkStartIndex &&
        index < _publicationChunkStartIndex + PublicationsSection.chunkCount) {
      final section = PublicationsSection(
        controller: _publicationsController,
        chunkIndex: index - _publicationChunkStartIndex,
        onPageChanged: () {
          unawaited(scrollToSectionById('publications'));
        },
      );
      return _withSectionTheme(section, animateTheme: animateTheme);
    }
    return _buildSection(sectionId!, animateTheme: animateTheme);
  }

  Widget _buildSection(String sectionId, {required bool animateTheme}) {
    final section = switch (sectionId) {
      'hero' => HeroSection(
        isDarkMode: widget.isDarkMode,
        onViewWork: () => scrollToSectionById('publications'),
      ),
      'about' => const AboutSection(),
      'work' => WorkExperienceSection(entries: _cvData?.workExperience),
      'education' => EducationSection(entries: _cvData?.education),
      'conferences' => ConferencesSeminarsSection(
        entries: _cvData?.conferences,
      ),
      'skills' => SkillsSection(data: _cvData?.skills),
      'languages' => LanguagesSection(data: _languageData),
      'astrogods' => const AstroGodsSection(),
      'contact' => ContactSection(currentLocale: widget.currentLocale),
      _ => throw ArgumentError.value(sectionId, 'sectionId'),
    };
    return _withSectionTheme(section, animateTheme: animateTheme);
  }

  Widget _withSectionTheme(Widget section, {required bool animateTheme}) {
    if (animateTheme) {
      return section;
    }
    return Theme(
      data: widget.isDarkMode
          ? PortfolioTheme.darkTheme
          : PortfolioTheme.lightTheme,
      child: section,
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
            colors: Theme.of(context).brightness == Brightness.dark
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
          hoverColor: isClose
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
            key: const ValueKey('theme-toggle'),
            heroTag: "theme_toggle",
            shape: const CircleBorder(),
            onPressed: widget.onThemeToggle,
            backgroundColor: Theme.of(context).colorScheme.primary,
            tooltip: widget.isDarkMode
                ? AppLocalizations.of(context)!.lightModeIconAlt
                : AppLocalizations.of(context)!.darkModeIconAlt,
            child: Semantics(
              button: true,
              label: widget.isDarkMode
                  ? AppLocalizations.of(context)!.lightModeIconAlt
                  : AppLocalizations.of(context)!.darkModeIconAlt,
              child: ThemeToggleWidget(
                isDarkMode: widget.isDarkMode,
                size: 56.0,
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
            onPressed: (_isDownloadingCV || _isDownloadingEuropassCV)
                ? null
                : _showCVDownloadDialog,
            backgroundColor: Theme.of(context).colorScheme.error,
            tooltip: (_isDownloadingCV || _isDownloadingEuropassCV)
                ? AppLocalizations.of(context)!.downloadingCV
                : AppLocalizations.of(context)!.downloadCV,
            child: (_isDownloadingCV || _isDownloadingEuropassCV)
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
            key: const ValueKey('toc-toggle'),
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
    final menuAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(menuAnimation);

    Widget menuButton({required double bottom, required Widget child}) {
      return Positioned(
        right: 0,
        bottom: bottom,
        child: IgnorePointer(
          ignoring: !_isFabExpanded,
          child: FadeTransition(
            opacity: menuAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          ),
        ),
      );
    }

    return SizedBox(
      width: 56,
      height: 344,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          menuButton(
            bottom: 288,
            child: FloatingActionButton(
              key: const ValueKey('theme-toggle-mobile'),
              heroTag: "theme_toggle_mobile",
              shape: const CircleBorder(),
              onPressed: () {
                widget.onThemeToggle();
                _toggleFab();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: widget.isDarkMode
                  ? AppLocalizations.of(context)!.lightModeIconAlt
                  : AppLocalizations.of(context)!.darkModeIconAlt,
              child: Semantics(
                button: true,
                label: widget.isDarkMode
                    ? AppLocalizations.of(context)!.lightModeIconAlt
                    : AppLocalizations.of(context)!.darkModeIconAlt,
                child: ThemeToggleWidget(
                  isDarkMode: widget.isDarkMode,
                  size: 56.0,
                ),
              ),
            ),
          ),
          menuButton(
            bottom: 216,
            child: FloatingActionButton(
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
            ),
          ),
          menuButton(
            bottom: 144,
            child: FloatingActionButton(
              heroTag: "download_cv_mobile",
              shape: const CircleBorder(),
              onPressed: (_isDownloadingCV || _isDownloadingEuropassCV)
                  ? null
                  : () {
                      _showCVDownloadDialog();
                      _toggleFab();
                    },
              backgroundColor: Theme.of(context).colorScheme.error,
              tooltip: (_isDownloadingCV || _isDownloadingEuropassCV)
                  ? AppLocalizations.of(context)!.downloadingCV
                  : AppLocalizations.of(context)!.downloadCV,
              child: (_isDownloadingCV || _isDownloadingEuropassCV)
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
            ),
          ),
          menuButton(
            bottom: 72,
            child: FloatingActionButton(
              key: const ValueKey('toc-toggle-mobile'),
              heroTag: "table_of_contents_mobile",
              shape: const CircleBorder(),
              onPressed: () {
                _toggleToc();
                _toggleFab();
              },
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              tooltip: AppLocalizations.of(context)!.tableOfContents,
              child: Icon(
                _isTocVisible ? Icons.close : Icons.list_rounded,
                color: Theme.of(context).colorScheme.onTertiary,
                size: 24.0,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: "main_fab_mobile",
              shape: const CircleBorder(),
              onPressed: _toggleFab,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              child: RotationTransition(
                turns: Tween<double>(
                  begin: 0,
                  end: 0.375,
                ).animate(menuAnimation),
                child: Icon(
                  _isFabExpanded ? Icons.close : Icons.settings,
                  color: Theme.of(context).colorScheme.onTertiary,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTocOverlay(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
                  onSectionSelected: scrollToSectionById,
                  onTap: _toggleToc,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return LanguageSelectorSheet(
          onLanguageChanged: widget.onLanguageChanged,
        );
      },
    );
  }
}
