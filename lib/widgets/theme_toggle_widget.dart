import 'package:flutter/material.dart';
import '../main.dart';

class ThemeToggleWidget extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;
  final double size;

  const ThemeToggleWidget({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    this.size = 24.0,
  });

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ThemeToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _controller.forward().then((_) {
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            decoration: BoxDecoration(
              color: PortfolioTheme.iceWhite,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Transform.scale(
                scale: 1.4,
                child:
                    widget.isDarkMode
                        ? Image.asset(
                          'assets/images/light_mode.png',
                          fit: BoxFit.cover,
                        )
                        : Transform.translate(
                          offset: const Offset(5.0, 2.0),
                          child: Image.asset(
                            'assets/images/dark_mode_button.png',
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
