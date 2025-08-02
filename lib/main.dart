import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/publications_section.dart';

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
  ThemeMode _themeMode = ThemeMode.dark;

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

class LandingPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildAboutSection(context),
            _buildSkillsSection(context),
            const PublicationsSection(),
            _buildContactSection(context),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingControls(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
            mini: true,
            onPressed: onThemeToggle,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "language_selector",
            mini: true,
            onPressed: () => _showLanguageSelector(context),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
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
                'Select Language',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                onTap: () {
                  onLanguageChanged(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇮🇹'),
                title: const Text('Italiano'),
                onTap: () {
                  onLanguageChanged(const Locale('it'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇪🇸'),
                title: const Text('Español'),
                onTap: () {
                  onLanguageChanged(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  PortfolioTheme.cobaltBlue,
                  PortfolioTheme.violet,
                ]
              : [
                  PortfolioTheme.cobaltBlue,
                  PortfolioTheme.emeraldGreen,
                ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: PortfolioTheme.iceWhite,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: isDark 
                        ? PortfolioTheme.wine 
                        : PortfolioTheme.cobaltBlue,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: PortfolioTheme.iceWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.jobTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: PortfolioTheme.iceWhite.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark 
                        ? PortfolioTheme.iceWhite 
                        : PortfolioTheme.iceWhite,
                    foregroundColor: isDark 
                        ? PortfolioTheme.cobaltBlue 
                        : PortfolioTheme.cobaltBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    elevation: 4,
                  ),
                  child: Text(AppLocalizations.of(context)!.viewMyWork),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.aboutMe,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.aboutMeDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skills = [
      l10n.skillFlutter,
      l10n.skillDart,
      l10n.skillJavaScript,
      l10n.skillPython,
      l10n.skillUIUX,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.skills,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                skills
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.getInTouch,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.email),
                iconSize: 32,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.web),
                iconSize: 32,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.code),
                iconSize: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.copyright,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
