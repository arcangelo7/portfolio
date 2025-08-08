import 'package:flutter/material.dart';

/// A lightweight lazy-loading image widget for assets.
///
/// - Defers decoding and painting of the underlying image until it is about to
///   enter the viewport (preloads ~200px before it appears).
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

  /// Creates a [LazyImage] that displays an asset image lazily when near view.
  /// Set [critical] to true for images that need immediate loading (e.g., theme icons).
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
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    // Schedule a post-frame check so images already in view load without requiring a scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check when inherited widgets like MediaQuery/Scrollables change.
    _checkVisibility();

    // Attach to the nearest Scrollable's position to react to scrolls (if any).
    final ScrollableState? scrollableState = Scrollable.maybeOf(context);
    if (scrollableState?.position != _scrollPosition) {
      _detachScrollListener();
      _scrollPosition = scrollableState?.position;
      _scrollPosition?.addListener(_checkVisibility);
    }
  }

  @override
  void dispose() {
    _detachScrollListener();
    super.dispose();
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            _checkVisibility();
            return false;
          },
          child: _buildImageContainer(),
        );
      },
    );
  }

  /// Checks whether this widget's render box is in or near the viewport and, if so,
  /// marks the image as visible so it can be built and decoded.
  void _checkVisibility() {
    if (_hasBeenVisible || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox?.hasSize != true) return;

    final position = renderBox!.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Consider the image visible if within the viewport or close to it (±200px)
    final isInOrNearViewport =
        position.dy < screenHeight + 200 && (position.dy + size.height) > -200;

    if (isInOrNearViewport && !_isVisible) {
      setState(() {
        _isVisible = true;
        _hasBeenVisible = true;
      });
      // Once visible, no need to keep listening for scrolls for this widget.
      _detachScrollListener();
    }
  }

  Widget _buildImageContainer() {
    // For critical images, skip lazy loading entirely
    if (widget.critical) {
      return _buildImage();
    }
    
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

    return _buildImage();
  }

  Widget _buildImage() {
    // Load actual image
    final imageWidget = Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      semanticLabel: widget.semanticLabel,
      errorBuilder: widget.errorBuilder,
      filterQuality: widget.filterQuality,
      alignment: widget.alignment,
      // Use frameBuilder to show loading indicator for non-critical images
      frameBuilder: widget.critical ? null : (context, child, frame, wasSynchronouslyLoaded) {
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
    if (widget.semanticLabel == null || widget.semanticLabel!.isEmpty) {
      return ExcludeSemantics(child: imageWidget);
    }
    return imageWidget;
  }
}
