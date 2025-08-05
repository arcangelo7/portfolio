import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarryBackground extends StatefulWidget {
  final Widget child;
  final bool showHorizon;

  const StarryBackground({
    super.key,
    required this.child,
    this.showHorizon = true,
  });

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController1;
  late AnimationController _animationController2;
  late AnimationController _animationController3;

  @override
  void initState() {
    super.initState();

    // Different speeds for different star layers
    _animationController1 = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    )..repeat();

    _animationController2 = AnimationController(
      duration: const Duration(seconds: 100),
      vsync: this,
    )..repeat();

    _animationController3 = AnimationController(
      duration: const Duration(seconds: 150),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController1.dispose();
    _animationController2.dispose();
    _animationController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.0,
          colors: [
            Color(0xFF0c1116), // Dark blue at bottom
            Color(0xFF090a0f), // Almost black at top
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Stars layer 1 (small, fast)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController1,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(
                    animationValue: _animationController1.value,
                    starSize: 1.0,
                    starCount: 700,
                    seed: 1,
                  ),
                );
              },
            ),
          ),

          // Stars layer 2 (medium, medium speed)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController2,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(
                    animationValue: _animationController2.value,
                    starSize: 2.0,
                    starCount: 200,
                    seed: 2,
                  ),
                );
              },
            ),
          ),

          // Stars layer 3 (large, slow)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController3,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(
                    animationValue: _animationController3.value,
                    starSize: 3.0,
                    starCount: 100,
                    seed: 3,
                  ),
                );
              },
            ),
          ),

          // Horizon effect
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

          // Earth silhouette
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

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final double animationValue;
  final double starSize;
  final int starCount;
  final int seed;

  StarPainter({
    required this.animationValue,
    required this.starSize,
    required this.starCount,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final random = math.Random(seed);

    for (int i = 0; i < starCount; i++) {
      // Generate consistent positions based on seed
      final x = random.nextDouble() * size.width * 1.6; // Wider for animation
      final baseY =
          random.nextDouble() * size.height * 2; // Taller for animation

      // Animate stars moving upward and looping
      final y =
          (baseY - (animationValue * size.height * 2)) % (size.height * 2);

      // Only draw stars that are visible
      if (y >= -starSize &&
          y <= size.height + starSize &&
          x >= -starSize &&
          x <= size.width + starSize) {
        // Add some twinkle effect
        final twinkle =
            (math.sin(animationValue * math.pi * 2 + i * 0.1) + 1) * 0.5;
        paint.color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.7);

        canvas.drawCircle(
          Offset(x, y),
          starSize * (0.5 + twinkle * 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
