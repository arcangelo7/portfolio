// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/responsive.dart';
import 'lazy_image.dart';
import 'orbiting_planets_widget.dart';
import 'starry_background.dart';

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

  List<Color> _gradientColors(bool isDarkMode) {
    return isDarkMode
        ? [PortfolioTheme.cobaltBlue, PortfolioTheme.astroMysticBlue]
        : [PortfolioTheme.emeraldGreen, PortfolioTheme.astroGold];
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
                  final previousColors = _gradientColors(_previousDarkMode);
                  final finalColors = _gradientColors(widget.isDarkMode);
                  return DecoratedBox(
                    key: const ValueKey('hero-gradient'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          Color.lerp(
                            previousColors[0],
                            finalColors[0],
                            _gradientAnimation.value,
                          )!,
                          Color.lerp(
                            previousColors[1],
                            finalColors[1],
                            _gradientAnimation.value,
                          )!,
                        ],
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
                elementSize: isMobile ? 120.0 : 180.0,
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
          Positioned(
            key: const ValueKey('hero-text-layer'),
            left: isMobile ? 16 : 60,
            right: isMobile ? 16 : null,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: isMobile ? null : screenWidth * 0.4,
              child: RepaintBoundary(
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
                        textAlign: isMobile
                            ? TextAlign.center
                            : TextAlign.start,
                        semanticsLabel: 'Main heading: ${l10n.name}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      l10n.professionalTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PortfolioTheme.iceWhite.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 18 : 24,
                        height: 1.3,
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
                      onPressed: widget.onViewWork,
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
                        l10n.viewMyWork,
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
          ),
        ],
      ),
    );
  }
}
