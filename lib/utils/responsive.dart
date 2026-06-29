// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/widgets.dart';

class Responsive {
  static const double mobileMaxWidth = 768;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileMaxWidth;
  }

  static Size sizeOf(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }
}
