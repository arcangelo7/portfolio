// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arcangelo Massari Portfolio';

  @override
  String get name => 'Arcangelo Massari';

  @override
  String get jobTitle => 'PhD Candidate in Digital Humanities';

  @override
  String get viewMyWork => 'View My Work';

  @override
  String get aboutMe => 'About Me';

  @override
  String get aboutMeDescription =>
      'I am a PhD candidate at the University of Bologna and KU Leuven, specializing in Digital Humanities and digital cultural heritage. My research focuses on Semantic Web, bibliographic metadata, and OpenCitations. I won the Gigliozzi Prize 2024 for the best contribution in digital humanities.';

  @override
  String get skills => 'Skills';

  @override
  String get getInTouch => 'Get In Touch';

  @override
  String get copyright => '© 2025 Arcangelo Massari. All rights reserved.';

  @override
  String get skillFlutter => 'Flutter';

  @override
  String get skillDart => 'Dart';

  @override
  String get skillJavaScript => 'JavaScript';

  @override
  String get skillPython => 'Python';

  @override
  String get skillUIUX => 'UI/UX Design';

  @override
  String get publications => 'Publications';

  @override
  String get loadingPublications => 'Loading publications...';

  @override
  String get noPublications => 'No publications available';

  @override
  String get viewDoi => 'View DOI';

  @override
  String get viewUrl => 'View Article';

  @override
  String get publicationsDescription =>
      'Selected academic publications and research contributions';
}
