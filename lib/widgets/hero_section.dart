// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/design_tokens.dart';
import '../theme/portfolio_theme.dart';
import '../utils/responsive.dart';
import 'lazy_image.dart';
import 'orbiting_planets_widget.dart';
import 'starry_background.dart';

/// How far the mascot's light reaches, as a multiple of the mascot itself.
/// Tying the halo to what casts it, rather than to the viewport, keeps the two
/// the same size relative to each other on every screen.
const double _glowSpread = 3.5;

class HeroSection extends StatefulWidget {
  final VoidCallback onViewWork;
  final bool isDarkMode;

  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.isDarkMode,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _themeController;
  late final Animation<double> _gradientAnimation;
  late bool _previousDarkMode;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _previousDarkMode = widget.isDarkMode;
    _themeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      value: 1,
      vsync: this,
    )..addStatusListener(_handleThemeAnimationStatus);
    _gradientAnimation = CurvedAnimation(
      parent: _themeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      precacheImage(const AssetImage('assets/images/light_mode.png'), context);
      precacheImage(const AssetImage('assets/images/dark_mode.png'), context);
      precacheImage(
        const AssetImage('assets/images/profile_cutout.webp'),
        context,
      );
    }
  }

  @override
  void didUpdateWidget(HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode == widget.isDarkMode) {
      return;
    }

    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      _previousDarkMode = widget.isDarkMode;
      _themeController.value = 1;
      return;
    }

    _previousDarkMode = oldWidget.isDarkMode;
    _themeController.forward(from: 0);
  }

  void _handleThemeAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _previousDarkMode != widget.isDarkMode &&
        mounted) {
      setState(() {
        _previousDarkMode = widget.isDarkMode;
      });
    }
  }

  @override
  void dispose() {
    _themeController
      ..removeStatusListener(_handleThemeAnimationStatus)
      ..dispose();
    super.dispose();
  }

  /// The sky lightens towards the corner the sun or moon occupies.
  List<Color> _skyColors(bool isDarkMode) {
    return isDarkMode ? PortfolioTheme.heroNightSky : PortfolioTheme.heroDaySky;
  }

  List<Color> _glowColors(bool isDarkMode) {
    return isDarkMode
        ? PortfolioTheme.heroNightGlow
        : PortfolioTheme.heroDayGlow;
  }

  List<Color> _lerpColors(List<Color> from, List<Color> to) {
    return [
      for (var i = 0; i < to.length; i++)
        Color.lerp(from[i], to[i], _gradientAnimation.value)!,
    ];
  }

  double get _starOpacity {
    if (_previousDarkMode == widget.isDarkMode) {
      return widget.isDarkMode ? 1 : 0;
    }
    return _previousDarkMode
        ? 1 - _gradientAnimation.value
        : _gradientAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = Responsive.sizeOf(context);
    final screenWidth = screenSize.width;
    final isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;
    final animateStars = widget.isDarkMode || _previousDarkMode;
    final mascot = MascotPlacement.of(context);
    final glowRadius = mascot.diameter * _glowSpread;

    return SizedBox(
      height: screenSize.height,
      child: Stack(
        children: [
          Positioned.fill(
            key: const ValueKey('hero-gradient-layer'),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  return DecoratedBox(
                    key: const ValueKey('hero-gradient'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: _lerpColors(
                          _skyColors(_previousDarkMode),
                          _skyColors(widget.isDarkMode),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            key: const ValueKey('hero-glow-layer'),
            left: mascot.center.dx - glowRadius,
            top: mascot.center.dy - glowRadius,
            width: glowRadius * 2,
            height: glowRadius * 2,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  return DecoratedBox(
                    key: const ValueKey('hero-glow'),
                    // The box is the halo, so the gradient keeps its default
                    // centre and radius and lands its last stop on the edge.
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        stops: const [0, 0.35, 1],
                        colors: _lerpColors(
                          _glowColors(_previousDarkMode),
                          _glowColors(widget.isDarkMode),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('hero-stars-layer'),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _gradientAnimation,
                child: StarryBackground(
                  key: const ValueKey('hero-stars'),
                  enableAnimation: animateStars,
                  showHorizon: false,
                  child: const SizedBox.expand(),
                ),
                builder: (context, child) {
                  return Opacity(
                    key: const ValueKey('hero-stars-opacity'),
                    opacity: _starOpacity,
                    child: child,
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('hero-theme-elements-layer'),
            child: RepaintBoundary(
              child: ThemeElementsTransition(
                previousDarkMode: _previousDarkMode,
                finalDarkMode: widget.isDarkMode,
                animation: _themeController,
              ),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('hero-portrait-layer'),
            child: RepaintBoundary(
              child: LazyImage(
                key: const ValueKey('hero-profile'),
                assetPath: 'assets/images/profile_cutout.webp',
                fit: screenWidth / screenSize.height > 2.1
                    ? BoxFit.contain
                    : BoxFit.cover,
                alignment: screenWidth / screenSize.height > 2.1
                    ? Alignment.bottomRight
                    : Alignment.center,
                semanticLabel: l10n.profileImageAlt,
                critical: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.person,
                      size: 200,
                      color: PortfolioTheme.iceWhite,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('hero-scrim-layer'),
            child: IgnorePointer(
              child: DecoratedBox(
                // Diagonal rather than straight across: the text needs the
                // shade, the corner the mascot lights does not, and a full
                // width scrim turns the dawn into a warm grey.
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: isMobile
                        ? Alignment.bottomCenter
                        : Alignment.bottomLeft,
                    end: isMobile ? Alignment.topCenter : Alignment.topRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.45, 0.85],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            key: const ValueKey('hero-text-layer'),
            left: isMobile ? Space.lg : Space.section,
            right: isMobile ? Space.lg : null,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: isMobile ? null : screenWidth * 0.5,
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: isMobile
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: SelectableText(
                              l10n.name,
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: PortfolioTheme.iceWhite,
                                    fontSize: _nameFontSize(screenSize),
                                  ),
                              textAlign: isMobile
                                  ? TextAlign.center
                                  : TextAlign.start,
                              semanticsLabel: 'Main heading: ${l10n.name}',
                            ),
                          ),
                          const SizedBox(height: Space.md),
                          SelectableText(
                            l10n.professionalTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: PortfolioTheme.iceWhite,
                                  fontWeight: FontWeight.w400,
                                  fontSize: isMobile ? 18 : 23,
                                ),
                            textAlign: isMobile
                                ? TextAlign.center
                                : TextAlign.start,
                          ),
                          const SizedBox(height: Space.xl),
                          FilledButton(
                            onPressed: widget.onViewWork,
                            style: FilledButton.styleFrom(
                              backgroundColor: PortfolioTheme.iceWhite,
                              foregroundColor: PortfolioTheme.cobaltBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Space.xl,
                                vertical: Space.md,
                              ),
                            ),
                            child: Text(l10n.viewMyWork),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fluid rather than two fixed steps, so the name fills the hero on a wide
  /// display without overrunning a short or narrow one.
  double _nameFontSize(Size screen) {
    return (screen.width * 0.062).clamp(38.0, 76.0);
  }
}
