import 'package:flutter/material.dart';

class LazyImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final FilterQuality filterQuality;
  final Alignment alignment;
  final bool critical;

  const LazyImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.errorBuilder,
    this.filterQuality = FilterQuality.low,
    this.alignment = Alignment.center,
    this.critical = false,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    // For critical images, skip lazy loading and load immediately
    if (widget.critical) {
      return _buildActualImage();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (!_hasBeenVisible) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox?.hasSize == true) {
                final position = renderBox!.localToGlobal(Offset.zero);
                final screenHeight = MediaQuery.of(context).size.height;
                
                // Check if image is within viewport or close to it (preload 200px before)
                final isInViewport = position.dy < screenHeight + 200 && 
                                   position.dy + renderBox.size.height > -200;
                
                if (isInViewport && !_isVisible) {
                  setState(() {
                    _isVisible = true;
                    _hasBeenVisible = true;
                  });
                }
              }
            }
            return false;
          },
          child: _buildImageContainer(),
        );
      },
    );
  }

  Widget _buildActualImage() {
    return Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      semanticLabel: widget.semanticLabel,
      errorBuilder: widget.errorBuilder,
      filterQuality: widget.filterQuality,
      alignment: widget.alignment,
    );
  }

  Widget _buildImageContainer() {
    if (!_isVisible && !_hasBeenVisible) {
      // Show placeholder while not visible
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      );
    }

    // Load actual image when visible
    return Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      semanticLabel: widget.semanticLabel,
      errorBuilder: widget.errorBuilder,
      filterQuality: widget.filterQuality,
      alignment: widget.alignment,
      // Use frameBuilder to show loading indicator
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}