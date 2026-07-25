// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The theme is the register the site is read in, and the site is written at
/// night: gold, the star field and AstroGods only belong to each other there.
/// So night is where a visitor arrives, and day is the register they can ask
/// for. The choice is then remembered and always wins.
class ThemePreferenceService {
  static const String _storageKey = 'theme_mode';

  static Future<ThemeMode> resolveInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    return stored == null ? ThemeMode.dark : ThemeMode.values.byName(stored);
  }

  static Future<void> store(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }
}
