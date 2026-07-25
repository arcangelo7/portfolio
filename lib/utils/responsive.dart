// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/widgets.dart';

import '../theme/design_tokens.dart';

enum ScreenTier { mobile, tablet, desktop }

class Responsive {
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1200;

  static ScreenTier tierOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMaxWidth) {
      return ScreenTier.mobile;
    }
    if (width < tabletMaxWidth) {
      return ScreenTier.tablet;
    }
    return ScreenTier.desktop;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletMaxWidth;
  }

  static Size sizeOf(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  /// Gutter between the viewport edge and the content column.
  static double pageInset(BuildContext context) {
    return switch (tierOf(context)) {
      ScreenTier.mobile => Space.lg,
      ScreenTier.tablet => Space.xxl,
      ScreenTier.desktop => Space.section,
    };
  }

  /// Vertical breathing room around a section's content.
  static double sectionInset(BuildContext context) {
    return switch (tierOf(context)) {
      ScreenTier.mobile => Space.xl,
      ScreenTier.tablet => Space.xxl,
      ScreenTier.desktop => Space.section,
    };
  }
}
