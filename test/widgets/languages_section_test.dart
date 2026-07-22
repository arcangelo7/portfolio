// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/models/language_data.dart';
import 'package:portfolio/widgets/languages_section.dart';

void main() {
  testWidgets('displays the localized certificate date', (
    WidgetTester tester,
  ) async {
    final languageData = LanguageData(
      motherTongue: MotherTongue(name: 'languagesItalian', order: 0),
      otherLanguages: [
        OtherLanguage(
          name: 'languagesEnglish',
          listening: 'C1',
          reading: 'C1',
          spokenInteraction: 'C1',
          spokenProduction: 'C1',
          writing: 'C1',
          certificateDate: DateTime(2026, 3, 7),
          badgeUrl: 'https://example.com/credential',
          order: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LanguagesSection(data: languageData),
          ),
        ),
      ),
    );

    expect(
      find.text('Certificazione conseguita il 7 mar 2026'),
      findsOneWidget,
    );
    expect(find.text('Verifica credenziale'), findsOneWidget);
  });
}
