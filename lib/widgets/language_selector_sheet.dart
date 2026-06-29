// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final ValueChanged<Locale> onLanguageChanged;

  const LanguageSelectorSheet({super.key, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _LanguageTile(
            locale: const Locale('en'),
            countryCode: 'US',
            title: 'English',
            semanticsLabel: l10n.changeLanguageToEnglish,
            onLanguageChanged: onLanguageChanged,
          ),
          _LanguageTile(
            locale: const Locale('it'),
            countryCode: 'IT',
            title: 'Italiano',
            semanticsLabel: l10n.changeLanguageToItalian,
            onLanguageChanged: onLanguageChanged,
          ),
          _LanguageTile(
            locale: const Locale('es'),
            countryCode: 'ES',
            title: 'Español',
            semanticsLabel: l10n.changeLanguageToSpanish,
            onLanguageChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final String countryCode;
  final String title;
  final String semanticsLabel;
  final ValueChanged<Locale> onLanguageChanged;

  const _LanguageTile({
    required this.locale,
    required this.countryCode,
    required this.title,
    required this.semanticsLabel,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ListTile(
        leading: CountryFlag.fromCountryCode(
          countryCode,
          theme: const ImageTheme(width: 20, height: 15),
        ),
        title: Text(title),
        onTap: () {
          onLanguageChanged(locale);
          Navigator.pop(context);
        },
      ),
    );
  }
}
