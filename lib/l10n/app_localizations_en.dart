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
      'I\'m currently doing my PhD between the University of Bologna and KU Leuven, working on Digital Humanities and digital cultural heritage. My research focuses on creating user-friendly interfaces for semantic data, specifically Semantic Web technologies with emphasis on change tracking and provenance. I won the [Gigliozzi Prize](https://www.aiucd.it/premio-gigliozzi-2024/) for the best presentation at AIUCD conference with [HERITRACE](https://opencitations.github.io/heritrace/), which is the main focus of my doctoral work.';

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
  String get viewPaper => 'View Paper';

  @override
  String get viewBook => 'View Book';

  @override
  String get viewChapter => 'View Chapter';

  @override
  String get viewSoftware => 'View Software';

  @override
  String get viewPresentation => 'View Presentation';

  @override
  String get publicationsDescription =>
      'My published research and academic work';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryJournalArticle => 'Journal Article';

  @override
  String get categoryConferencePaper => 'Conference Paper';

  @override
  String get categoryBook => 'Book';

  @override
  String get categoryBookSection => 'Book Section';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryPresentation => 'Presentation';

  @override
  String get categoryThesis => 'Thesis';

  @override
  String get categoryReport => 'Report';

  @override
  String get categoryOther => 'Other';

  @override
  String get noPublicationsForCategory =>
      'No publications found for the selected category';

  @override
  String get showAllAuthors => 'Show all authors';

  @override
  String get showLess => 'Show less';

  @override
  String andMoreAuthors(Object count) {
    return 'and $count more...';
  }

  @override
  String get abstract => 'Abstract';

  @override
  String get readMore => 'Read more';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';
}
