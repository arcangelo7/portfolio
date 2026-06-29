// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/responsive.dart';
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
      duration: const Duration(milliseconds: 650),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _transitionController.reset();
      }
    });

    _orbitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(StaticThemeElementsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (oldWidget.isDarkMode != widget.isDarkMode &&
        widget.enableAnimation &&
        !disableAnimations) {
      _transitionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Widget _buildPlanetElement(bool isDarkMode) {
    return Container(
      key: ValueKey(isDarkMode ? 'theme-element-moon' : 'theme-element-sun'),
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
        child: Semantics(
          image: true,
          label: AppLocalizations.of(context)?.orbitingPlanetAlt,
          child: ExcludeSemantics(
            excluding: true,
            child: LazyImage(
              assetPath:
                  isDarkMode
                      ? 'assets/images/dark_mode.png'
                      : 'assets/images/light_mode.png',
              fit: BoxFit.cover,
              width: widget.elementSize,
              height: widget.elementSize,
              critical: true,
              semanticLabel: AppLocalizations.of(context)?.orbitingPlanetAlt,
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionedPlanet({required bool isDarkMode, required Offset offset}) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: _buildPlanetElement(isDarkMode),
    );
  }

  double _lerp(double start, double end, double progress) {
    return start + (end - start) * progress;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = Responsive.sizeOf(context);
    final isMobile = Responsive.isMobile(context);

    final leftPosition = isMobile ? 20.0 : 40.0;
    final topPosition = isMobile ? 20.0 : 40.0;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        if (!_transitionController.isAnimating || disableAnimations) {
          return Positioned(
            left: leftPosition,
            top: topPosition,
            child: _buildPlanetElement(widget.isDarkMode),
          );
        }

        final progress = _orbitAnimation.value;
        final outgoingOffset = Offset(
          _lerp(leftPosition, screenSize.width + widget.elementSize, progress),
          _lerp(topPosition, screenSize.height * 0.7, progress) -
              screenSize.height * 0.12 * math.sin(progress * math.pi),
        );
        final incomingOffset = Offset(
          _lerp(-widget.elementSize, leftPosition, progress),
          _lerp(screenSize.height * 0.24, topPosition, progress) -
              screenSize.height * 0.06 * math.sin(progress * math.pi),
        );

        return Positioned.fill(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              _positionedPlanet(
                isDarkMode: !widget.isDarkMode,
                offset: outgoingOffset,
              ),
              _positionedPlanet(
                isDarkMode: widget.isDarkMode,
                offset: incomingOffset,
              ),
            ],
          ),
        );
      },
    );
  }
}
