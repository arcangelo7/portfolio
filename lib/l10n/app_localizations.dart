import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Arcangelo Massari Portfolio'**
  String get appTitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Arcangelo Massari'**
  String get name;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'PhD Candidate in Digital Humanities'**
  String get jobTitle;

  /// No description provided for @viewMyWork.
  ///
  /// In en, this message translates to:
  /// **'View My Work'**
  String get viewMyWork;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @aboutMeDescription.
  ///
  /// In en, this message translates to:
  /// **'I\'m currently doing my PhD between the University of Bologna and KU Leuven, working on Digital Humanities and digital cultural heritage. My research focuses on creating user-friendly interfaces for semantic data, specifically Semantic Web technologies with emphasis on change tracking and provenance. I won the [Gigliozzi Prize](https://www.aiucd.it/premio-gigliozzi-2024/) for the best presentation at AIUCD conference with [HERITRACE](https://opencitations.github.io/heritrace/), which is the main focus of my doctoral work.'**
  String get aboutMeDescription;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get In Touch'**
  String get getInTouch;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Arcangelo Massari. All rights reserved.'**
  String get copyright;

  /// No description provided for @skillFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get skillFlutter;

  /// No description provided for @skillDart.
  ///
  /// In en, this message translates to:
  /// **'Dart'**
  String get skillDart;

  /// No description provided for @skillJavaScript.
  ///
  /// In en, this message translates to:
  /// **'JavaScript'**
  String get skillJavaScript;

  /// No description provided for @skillPython.
  ///
  /// In en, this message translates to:
  /// **'Python'**
  String get skillPython;

  /// No description provided for @skillUIUX.
  ///
  /// In en, this message translates to:
  /// **'UI/UX Design'**
  String get skillUIUX;

  /// No description provided for @publications.
  ///
  /// In en, this message translates to:
  /// **'Publications'**
  String get publications;

  /// No description provided for @loadingPublications.
  ///
  /// In en, this message translates to:
  /// **'Loading publications...'**
  String get loadingPublications;

  /// No description provided for @noPublications.
  ///
  /// In en, this message translates to:
  /// **'No publications available'**
  String get noPublications;

  /// No description provided for @viewDoi.
  ///
  /// In en, this message translates to:
  /// **'View DOI'**
  String get viewDoi;

  /// No description provided for @viewUrl.
  ///
  /// In en, this message translates to:
  /// **'View Article'**
  String get viewUrl;

  /// No description provided for @viewPaper.
  ///
  /// In en, this message translates to:
  /// **'View Paper'**
  String get viewPaper;

  /// No description provided for @viewBook.
  ///
  /// In en, this message translates to:
  /// **'View Book'**
  String get viewBook;

  /// No description provided for @viewChapter.
  ///
  /// In en, this message translates to:
  /// **'View Chapter'**
  String get viewChapter;

  /// No description provided for @viewSoftware.
  ///
  /// In en, this message translates to:
  /// **'View Software'**
  String get viewSoftware;

  /// No description provided for @viewPresentation.
  ///
  /// In en, this message translates to:
  /// **'View Presentation'**
  String get viewPresentation;

  /// No description provided for @publicationsDescription.
  ///
  /// In en, this message translates to:
  /// **'My published research and academic work'**
  String get publicationsDescription;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryJournalArticle.
  ///
  /// In en, this message translates to:
  /// **'Journal Article'**
  String get categoryJournalArticle;

  /// No description provided for @categoryConferencePaper.
  ///
  /// In en, this message translates to:
  /// **'Conference Paper'**
  String get categoryConferencePaper;

  /// No description provided for @categoryBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get categoryBook;

  /// No description provided for @categoryBookSection.
  ///
  /// In en, this message translates to:
  /// **'Book Section'**
  String get categoryBookSection;

  /// No description provided for @categorySoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get categorySoftware;

  /// No description provided for @categoryPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get categoryPresentation;

  /// No description provided for @categoryThesis.
  ///
  /// In en, this message translates to:
  /// **'Thesis'**
  String get categoryThesis;

  /// No description provided for @categoryReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get categoryReport;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @noPublicationsForCategory.
  ///
  /// In en, this message translates to:
  /// **'No publications found for the selected category'**
  String get noPublicationsForCategory;

  /// No description provided for @showAllAuthors.
  ///
  /// In en, this message translates to:
  /// **'Show all authors'**
  String get showAllAuthors;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @andMoreAuthors.
  ///
  /// In en, this message translates to:
  /// **'and {count} more...'**
  String andMoreAuthors(Object count);

  /// No description provided for @abstract.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get abstract;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
