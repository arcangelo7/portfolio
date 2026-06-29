// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/material.dart';

class StarryBackground extends StatefulWidget {
  final Widget child;
  final bool showHorizon;
  final int starCount1;
  final int starCount2;
  final int starCount3;
  final double starSize1;
  final double starSize2;
  final double starSize3;
  final Color starColor;
  final int animationSpeed1;
  final int animationSpeed2;
  final int animationSpeed3;
  final bool forceNightBackground;

  const StarryBackground({
    super.key,
    required this.child,
    this.showHorizon = true,
    this.starCount1 = 700,
    this.starCount2 = 200,
    this.starCount3 = 100,
    this.starSize1 = 1.0,
    this.starSize2 = 2.0,
    this.starSize3 = 3.0,
    this.starColor = Colors.white,
    this.animationSpeed1 = 50,
    this.animationSpeed2 = 100,
    this.animationSpeed3 = 150,
    this.forceNightBackground = false,
  });

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<_StarLayer> _starLayers;
  late int _loopDurationSeconds;
  ScrollPosition? _scrollPosition;
  bool _isInOrNearViewport = false;
  bool _disableAnimations = false;
  double _viewportHeight = 0;

  @override
  void initState() {
    super.initState();
    _starLayers = _buildStarLayers();
    _loopDurationSeconds = _animationLoopSeconds();
    _animationController = AnimationController(
      duration: Duration(seconds: _loopDurationSeconds),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _viewportHeight = MediaQuery.sizeOf(context).height;
    _attachScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkVisibility();
    });
    _syncAnimation();
  }

  @override
  void didUpdateWidget(StarryBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_starLayerConfigurationChanged(oldWidget)) {
      _starLayers = _buildStarLayers();
    }

    final nextLoopDurationSeconds = _animationLoopSeconds();
    if (nextLoopDurationSeconds != _loopDurationSeconds) {
      _loopDurationSeconds = nextLoopDurationSeconds;
      _animationController.duration = Duration(seconds: _loopDurationSeconds);
      if (_animationController.isAnimating) {
        _animationController.repeat();
      }
    }
    _syncAnimation();
  }

  @override
  void dispose() {
    _detachScrollListener();
    _animationController.dispose();
    super.dispose();
  }

  List<_StarLayer> _buildStarLayers() {
    return [
      _StarLayer(
        stars: _buildStars(widget.starCount1, 1),
        starSize: widget.starSize1,
        animationSpeed: widget.animationSpeed1,
      ),
      _StarLayer(
        stars: _buildStars(widget.starCount2, 2),
        starSize: widget.starSize2,
        animationSpeed: widget.animationSpeed2,
      ),
      _StarLayer(
        stars: _buildStars(widget.starCount3, 3),
        starSize: widget.starSize3,
        animationSpeed: widget.animationSpeed3,
      ),
    ];
  }

  List<_StarPoint> _buildStars(int starCount, int seed) {
    final random = math.Random(seed);
    return List.generate(starCount, (_) {
      return _StarPoint(
        xFactor: random.nextDouble() * 1.6,
        yFactor: random.nextDouble() * 2,
        phase: random.nextDouble() * math.pi * 2,
      );
    });
  }

  bool _starLayerConfigurationChanged(StarryBackground oldWidget) {
    return oldWidget.starCount1 != widget.starCount1 ||
        oldWidget.starCount2 != widget.starCount2 ||
        oldWidget.starCount3 != widget.starCount3 ||
        oldWidget.starSize1 != widget.starSize1 ||
        oldWidget.starSize2 != widget.starSize2 ||
        oldWidget.starSize3 != widget.starSize3 ||
        oldWidget.animationSpeed1 != widget.animationSpeed1 ||
        oldWidget.animationSpeed2 != widget.animationSpeed2 ||
        oldWidget.animationSpeed3 != widget.animationSpeed3;
  }

  int _animationLoopSeconds() {
    return _leastCommonMultiple(
      _leastCommonMultiple(widget.animationSpeed1, widget.animationSpeed2),
      widget.animationSpeed3,
    );
  }

  int _greatestCommonDivisor(int a, int b) {
    while (b != 0) {
      final next = b;
      b = a % b;
      a = next;
    }
    return a;
  }

  int _leastCommonMultiple(int a, int b) {
    return a ~/ _greatestCommonDivisor(a, b) * b;
  }

  void _attachScrollListener() {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState?.position == _scrollPosition) return;

    _detachScrollListener();
    _scrollPosition = scrollableState?.position;
    _scrollPosition?.addListener(_checkVisibility);
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
  }

  void _checkVisibility() {
    if (!mounted) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final position = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final isInOrNearViewport =
        position.dy < _viewportHeight + 200 && position.dy + size.height > -200;

    if (isInOrNearViewport == _isInOrNearViewport) return;

    setState(() {
      _isInOrNearViewport = isInOrNearViewport;
    });
    _syncAnimation();
  }

  void _syncAnimation() {
    final shouldAnimate = !_disableAnimations && _isInOrNearViewport;
    if (shouldAnimate && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!shouldAnimate && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = !_disableAnimations && _isInOrNearViewport;

    return Container(
      decoration:
          widget.forceNightBackground
              ? const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.0,
                  colors: [Color(0xFF0c1116), Color(0xFF090a0f)],
                  stops: [0.0, 1.0],
                ),
              )
              : const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: shouldAnimate,
                painter: _StarPainter(
                  animation: _animationController,
                  layers: _starLayers,
                  loopDurationSeconds: _loopDurationSeconds,
                  starColor: widget.starColor,
                  animate: shouldAnimate,
                ),
              ),
            ),
          ),
          if (widget.showHorizon)
            Positioned(
              bottom: -200,
              left: -200,
              right: -200,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.8,
                    colors: [
                      const Color(0xFF038bff).withValues(alpha: 0.3),
                      const Color(0xFF51AFFF).withValues(alpha: 0.2),
                      const Color(0xFFB0DAFF).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          if (widget.showHorizon)
            Positioned(
              bottom: -1500,
              left: -800,
              right: -800,
              child: Container(
                height: 1700,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.9), Colors.black],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF215496).withValues(alpha: 0.5),
                      blurRadius: 80,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _StarLayer {
  final List<_StarPoint> stars;
  final double starSize;
  final int animationSpeed;

  const _StarLayer({
    required this.stars,
    required this.starSize,
    required this.animationSpeed,
  });
}

class _StarPoint {
  final double xFactor;
  final double yFactor;
  final double phase;

  const _StarPoint({
    required this.xFactor,
    required this.yFactor,
    required this.phase,
  });
}

class _StarPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_StarLayer> layers;
  final int loopDurationSeconds;
  final Color starColor;
  final bool animate;

  _StarPainter({
    required this.animation,
    required this.layers,
    required this.loopDurationSeconds,
    this.starColor = Colors.white,
    required this.animate,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final animationValue = animate ? animation.value : 0.0;
    final elapsedSeconds = animationValue * loopDurationSeconds;

    for (final layer in layers) {
      final layerProgress =
          animate
              ? (elapsedSeconds % layer.animationSpeed) / layer.animationSpeed
              : 0.0;

      for (final star in layer.stars) {
        final x = star.xFactor * size.width;
        final baseY = star.yFactor * size.height;
        final y = (baseY - layerProgress * size.height * 2) % (size.height * 2);

        if (y >= -layer.starSize &&
            y <= size.height + layer.starSize &&
            x >= -layer.starSize &&
            x <= size.width + layer.starSize) {
          final twinkle =
              (math.sin(layerProgress * math.pi * 2 + star.phase) + 1) * 0.5;
          paint.color = starColor.withValues(alpha: 0.3 + twinkle * 0.7);

          canvas.drawCircle(
            Offset(x, y),
            layer.starSize * (0.5 + twinkle * 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.loopDurationSeconds != loopDurationSeconds ||
        oldDelegate.starColor != starColor ||
        oldDelegate.animate != animate;
  }
}
