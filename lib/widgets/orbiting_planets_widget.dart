import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';
import 'lazy_image.dart';

class StaticThemeElementsWidget extends StatefulWidget {
  final bool isDarkMode;
  final double elementSize;
  final bool enableAnimation;

  const StaticThemeElementsWidget({
    super.key,
    required this.isDarkMode,
    this.elementSize = 60.0,
    this.enableAnimation = true,
  });

  @override
  State<StaticThemeElementsWidget> createState() =>
      _StaticThemeElementsWidgetState();
}

class _StaticThemeElementsWidgetState extends State<StaticThemeElementsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _orbitAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(StaticThemeElementsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode && widget.enableAnimation) {
      _transitionController.forward().then((_) {
        _transitionController.reset();
      });
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Widget _buildPlanetElement(
    String assetPath,
    IconData fallbackIcon,
    Color fallbackColor,
  ) {
    return Container(
      width: widget.elementSize,
      height: widget.elementSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: LazyImage(
          assetPath: assetPath,
          fit: BoxFit.cover,
          width: widget.elementSize,
          height: widget.elementSize,
          critical: true, // Orbiting planets are in hero section, load immediately
          semanticLabel: AppLocalizations.of(context)?.orbitingPlanetAlt,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fallbackColor,
              ),
              child: Icon(
                fallbackIcon,
                color: Colors.white,
                size: widget.elementSize * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    // Static position in top-left corner with equal distance from left and top
    final leftPosition = isMobile ? 20.0 : 40.0;
    final topPosition = isMobile ? 20.0 : 40.0;

    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        if (!_transitionController.isAnimating) {
          // Static position when not animating
          return Positioned(
            left: leftPosition,
            top: topPosition,
            child:
                widget.isDarkMode
                    ? _buildPlanetElement(
                      'assets/images/dark_mode.png',
                      Icons.nightlight_round,
                      Colors.indigo,
                    )
                    : _buildPlanetElement(
                      'assets/images/light_mode.png',
                      Icons.wb_sunny,
                      Colors.orange,
                    ),
          );
        }

        // During transition: animate along elliptical path
        final progress = _orbitAnimation.value / (2 * math.pi);

        // Use simple linear interpolation to ensure exact start position
        final startX = leftPosition;
        final startY = topPosition;
        final endX = screenSize.width + widget.elementSize;
        final endY = screenSize.height * 0.7;

        // Simple interpolation for X (linear left to right)
        final x = startX + (endX - startX) * progress;

        // Elliptical curve for Y to create natural arc
        final midY =
            topPosition - (screenSize.height * 0.1); // Arc upward first
        final y =
            startY +
            (midY - startY) *
                2 *
                progress *
                (1 - progress) + // Quadratic curve up then down
            (endY - startY) * progress;

        return Stack(
          children: [
            // Exiting element (moves from left to right and exits completely)
            if (progress < 1.0)
              Positioned(
                left: x,
                top: y,
                child:
                    widget.isDarkMode
                        ? _buildPlanetElement(
                          'assets/images/light_mode.png',
                          Icons.wb_sunny,
                          Colors.orange,
                        )
                        : _buildPlanetElement(
                          'assets/images/dark_mode.png',
                          Icons.nightlight_round,
                          Colors.indigo,
                        ),
              ),
            // Entering element (appears from left side after the other exits)
            if (progress >= 1.0)
              Positioned(
                left: leftPosition,
                top: topPosition,
                child:
                    widget.isDarkMode
                        ? _buildPlanetElement(
                          'assets/images/dark_mode.png',
                          Icons.nightlight_round,
                          Colors.indigo,
                        )
                        : _buildPlanetElement(
                          'assets/images/light_mode.png',
                          Icons.wb_sunny,
                          Colors.orange,
                        ),
              ),
          ],
        );
      },
    );
  }
}
