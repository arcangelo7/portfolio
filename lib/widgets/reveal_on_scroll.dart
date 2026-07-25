// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Fades a section up the first time it reaches the viewport, once, and never
/// again. The list builds items up to a viewport early, so the trigger is the
/// real position of the box rather than the moment it is created.
///
/// It listens to the enclosing scroll position: scroll notifications travel up
/// from the scrollable, so an item inside the list never receives them.
class RevealOnScroll extends StatefulWidget {
  final Widget child;

  const RevealOnScroll({super.key, required this.child});

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.reveal,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.enter,
  );
  ScrollPosition? _position;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealIfVisible());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_revealed && MediaQuery.of(context).disableAnimations) {
      _reveal(animate: false);
      return;
    }

    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _detach();
      _position = position;
      _position?.addListener(_revealIfVisible);
    }
  }

  @override
  void dispose() {
    _detach();
    _controller.dispose();
    super.dispose();
  }

  void _detach() {
    _position?.removeListener(_revealIfVisible);
    _position = null;
  }

  void _reveal({bool animate = true}) {
    _revealed = true;
    _detach();
    if (animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  void _revealIfVisible() {
    if (_revealed || !mounted) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    if (box.localToGlobal(Offset.zero).dy <
        MediaQuery.sizeOf(context).height * 0.92) {
      _reveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curve.value) * 12),
            child: child,
          ),
        );
      },
    );
  }
}
