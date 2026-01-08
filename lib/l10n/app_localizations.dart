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

  /// No description provided for @seoDescription.
  ///
  /// In en, this message translates to:
  /// **'PhD candidate in Digital Humanities at University of Bologna and KU Leuven. Research on Semantic Web, provenance, change tracking, and cultural heritage.'**
  String get seoDescription;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Arcangelo Massari'**
  String get name;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'PhD candidate in Digital Humanities'**
  String get jobTitle;

  /// No description provided for @viewMyWork.
  ///
  /// In en, this message translates to:
  /// **'Check out my projects'**
  String get viewMyWork;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @aboutMeDescription.
  ///
  /// In en, this message translates to:
  /// **'I\'m pursuing a PhD in cultural heritage in digital ecosystem between the University of Bologna and KU Leuven. My research focuses on creating user-friendly interfaces for semantic data, specifically Semantic Web technologies with emphasis on change tracking and provenance. I won the [Gigliozzi Prize](https://www.aiucd.it/premio-gigliozzi-2024/) for the best presentation at AIUCD 2024 conference with [HERITRACE](https://opencitations.github.io/heritrace/), which is the main focus of my doctoral work.'**
  String get aboutMeDescription;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'My toolbox'**
  String get skills;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Find me online'**
  String get getInTouch;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Arcangelo Massari. All rights are illusion.'**
  String get copyright;

  /// No description provided for @laoTzuQuote.
  ///
  /// In en, this message translates to:
  /// **'\'Those who have virtue (Dharma) attend to their duty,\nthose who have no virtue attend to their presumed rights.\'\n— Lao Tzu, Tao Te Ching'**
  String get laoTzuQuote;

  /// No description provided for @skillCategoryProgrammingLanguages.
  ///
  /// In en, this message translates to:
  /// **'Programming languages'**
  String get skillCategoryProgrammingLanguages;

  /// No description provided for @skillCategoryWebTechnologies.
  ///
  /// In en, this message translates to:
  /// **'Web technologies'**
  String get skillCategoryWebTechnologies;

  /// No description provided for @skillCategoryQueryLanguages.
  ///
  /// In en, this message translates to:
  /// **'Query languages'**
  String get skillCategoryQueryLanguages;

  /// No description provided for @skillCategorySemanticWebTechnologies.
  ///
  /// In en, this message translates to:
  /// **'Semantic Web technologies'**
  String get skillCategorySemanticWebTechnologies;

  /// No description provided for @skillCategoryFrontendLibraries.
  ///
  /// In en, this message translates to:
  /// **'Frontend libraries'**
  String get skillCategoryFrontendLibraries;

  /// No description provided for @skillCategoryBackendFrameworks.
  ///
  /// In en, this message translates to:
  /// **'Backend frameworks'**
  String get skillCategoryBackendFrameworks;

  /// No description provided for @skillCategoryDatabases.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get skillCategoryDatabases;

  /// No description provided for @skillCategoryInfrastructureDevOps.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure & DevOps'**
  String get skillCategoryInfrastructureDevOps;

  /// No description provided for @skillCategoryOperatingSystems.
  ///
  /// In en, this message translates to:
  /// **'Linux distributions'**
  String get skillCategoryOperatingSystems;

  /// No description provided for @skillPython.
  ///
  /// In en, this message translates to:
  /// **'Python'**
  String get skillPython;

  /// No description provided for @skillJavaScript.
  ///
  /// In en, this message translates to:
  /// **'JavaScript'**
  String get skillJavaScript;

  /// No description provided for @skillTypeScript.
  ///
  /// In en, this message translates to:
  /// **'TypeScript'**
  String get skillTypeScript;

  /// No description provided for @skillDart.
  ///
  /// In en, this message translates to:
  /// **'Dart'**
  String get skillDart;

  /// No description provided for @skillHTML5.
  ///
  /// In en, this message translates to:
  /// **'HTML5'**
  String get skillHTML5;

  /// No description provided for @skillCSS.
  ///
  /// In en, this message translates to:
  /// **'CSS'**
  String get skillCSS;

  /// No description provided for @skillSPARQL.
  ///
  /// In en, this message translates to:
  /// **'SPARQL'**
  String get skillSPARQL;

  /// No description provided for @skillSQL.
  ///
  /// In en, this message translates to:
  /// **'SQL'**
  String get skillSQL;

  /// No description provided for @skillRDFSerializations.
  ///
  /// In en, this message translates to:
  /// **'RDF and serializations (RDF/XML, JSON-LD, Turtle, N-Triples, N-Quads, TriG)'**
  String get skillRDFSerializations;

  /// No description provided for @skillSHACL.
  ///
  /// In en, this message translates to:
  /// **'SHACL'**
  String get skillSHACL;

  /// No description provided for @skillFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get skillFlutter;

  /// No description provided for @skillReact.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get skillReact;

  /// No description provided for @skillBootstrap.
  ///
  /// In en, this message translates to:
  /// **'Bootstrap'**
  String get skillBootstrap;

  /// No description provided for @skillNodeJS.
  ///
  /// In en, this message translates to:
  /// **'Node.js'**
  String get skillNodeJS;

  /// No description provided for @skillFlask.
  ///
  /// In en, this message translates to:
  /// **'Flask'**
  String get skillFlask;

  /// No description provided for @skillPrisma.
  ///
  /// In en, this message translates to:
  /// **'Prisma ORM'**
  String get skillPrisma;

  /// No description provided for @skillBlazeGraph.
  ///
  /// In en, this message translates to:
  /// **'BlazeGraph'**
  String get skillBlazeGraph;

  /// No description provided for @skillOpenLinkVirtuoso.
  ///
  /// In en, this message translates to:
  /// **'OpenLink Virtuoso'**
  String get skillOpenLinkVirtuoso;

  /// No description provided for @skillApacheJenaFuseki.
  ///
  /// In en, this message translates to:
  /// **'Apache Jena Fuseki'**
  String get skillApacheJenaFuseki;

  /// No description provided for @skillGraphDB.
  ///
  /// In en, this message translates to:
  /// **'GraphDB'**
  String get skillGraphDB;

  /// No description provided for @skillD3JS.
  ///
  /// In en, this message translates to:
  /// **'D3.js'**
  String get skillD3JS;

  /// No description provided for @skillMongoDB.
  ///
  /// In en, this message translates to:
  /// **'MongoDB'**
  String get skillMongoDB;

  /// No description provided for @skillPostgreSQL.
  ///
  /// In en, this message translates to:
  /// **'PostgreSQL'**
  String get skillPostgreSQL;

  /// No description provided for @skillRedis.
  ///
  /// In en, this message translates to:
  /// **'Redis'**
  String get skillRedis;

  /// No description provided for @skillDocker.
  ///
  /// In en, this message translates to:
  /// **'Docker'**
  String get skillDocker;

  /// No description provided for @skillProxmox.
  ///
  /// In en, this message translates to:
  /// **'Proxmox'**
  String get skillProxmox;

  /// No description provided for @skillDebian.
  ///
  /// In en, this message translates to:
  /// **'Debian'**
  String get skillDebian;

  /// No description provided for @skillFedora.
  ///
  /// In en, this message translates to:
  /// **'Fedora'**
  String get skillFedora;

  /// No description provided for @skillArch.
  ///
  /// In en, this message translates to:
  /// **'Arch Linux'**
  String get skillArch;

  /// No description provided for @skillGitHubActions.
  ///
  /// In en, this message translates to:
  /// **'GitHub Actions'**
  String get skillGitHubActions;

  /// No description provided for @publications.
  ///
  /// In en, this message translates to:
  /// **'For Science'**
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

  /// No description provided for @viewThesis.
  ///
  /// In en, this message translates to:
  /// **'View Thesis'**
  String get viewThesis;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @publicationsDescription.
  ///
  /// In en, this message translates to:
  /// **'My publications and academic contributions'**
  String get publicationsDescription;

  /// No description provided for @searchPublications.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, venue, year, or abstract...'**
  String get searchPublications;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryJournalArticle.
  ///
  /// In en, this message translates to:
  /// **'Journal article'**
  String get categoryJournalArticle;

  /// No description provided for @categoryConferencePaper.
  ///
  /// In en, this message translates to:
  /// **'Conference paper'**
  String get categoryConferencePaper;

  /// No description provided for @categoryBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get categoryBook;

  /// No description provided for @categoryBookSection.
  ///
  /// In en, this message translates to:
  /// **'Book section'**
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

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @loadingDescription.
  ///
  /// In en, this message translates to:
  /// **'Loading description...'**
  String get loadingDescription;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @citations.
  ///
  /// In en, this message translates to:
  /// **'Citations'**
  String get citations;

  /// No description provided for @totalCitations.
  ///
  /// In en, this message translates to:
  /// **'Total citations: {count}'**
  String totalCitations(Object count);

  /// No description provided for @calculatingTotalCitations.
  ///
  /// In en, this message translates to:
  /// **'Calculating total citations...'**
  String get calculatingTotalCitations;

  /// No description provided for @citationCount.
  ///
  /// In en, this message translates to:
  /// **'Cited {count} times'**
  String citationCount(Object count);

  /// No description provided for @noCitations.
  ///
  /// In en, this message translates to:
  /// **'No citations available'**
  String get noCitations;

  /// No description provided for @viewCitations.
  ///
  /// In en, this message translates to:
  /// **'View citations'**
  String get viewCitations;

  /// No description provided for @citationsFrom.
  ///
  /// In en, this message translates to:
  /// **'Citations from OpenCitations'**
  String get citationsFrom;

  /// No description provided for @loadingCitations.
  ///
  /// In en, this message translates to:
  /// **'Loading citations...'**
  String get loadingCitations;

  /// No description provided for @citedBy.
  ///
  /// In en, this message translates to:
  /// **'Citation from'**
  String get citedBy;

  /// No description provided for @citedOn.
  ///
  /// In en, this message translates to:
  /// **'Cited on'**
  String get citedOn;

  /// No description provided for @citation.
  ///
  /// In en, this message translates to:
  /// **'Citation'**
  String get citation;

  /// No description provided for @citationFrom.
  ///
  /// In en, this message translates to:
  /// **'Citation from'**
  String get citationFrom;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// No description provided for @unknownYear.
  ///
  /// In en, this message translates to:
  /// **'Unknown Year'**
  String get unknownYear;

  /// No description provided for @citedAfter.
  ///
  /// In en, this message translates to:
  /// **'Cited after'**
  String get citedAfter;

  /// No description provided for @unknownJournal.
  ///
  /// In en, this message translates to:
  /// **'Unknown Journal'**
  String get unknownJournal;

  /// No description provided for @citationId.
  ///
  /// In en, this message translates to:
  /// **'Citation ID'**
  String get citationId;

  /// No description provided for @timeSpan.
  ///
  /// In en, this message translates to:
  /// **'Time span'**
  String get timeSpan;

  /// No description provided for @doi.
  ///
  /// In en, this message translates to:
  /// **'DOI'**
  String get doi;

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

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @professionalWebsite.
  ///
  /// In en, this message translates to:
  /// **'Institutional website'**
  String get professionalWebsite;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @orcid.
  ///
  /// In en, this message translates to:
  /// **'ORCID'**
  String get orcid;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get twitter;

  /// No description provided for @workExperience.
  ///
  /// In en, this message translates to:
  /// **'Work experience'**
  String get workExperience;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @tutorTitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching tutor'**
  String get tutorTitle;

  /// No description provided for @universityBologna.
  ///
  /// In en, this message translates to:
  /// **'University of Bologna'**
  String get universityBologna;

  /// No description provided for @tutorPeriod.
  ///
  /// In en, this message translates to:
  /// **'Oct 2022 - Oct 2023, Oct 2025 - Present'**
  String get tutorPeriod;

  /// No description provided for @tutorDescription.
  ///
  /// In en, this message translates to:
  /// **'Laboratory sessions for [Computational Management of Data](https://www.unibo.it/en/study/course-units-transferable-skills-moocs/course-unit-catalogue/course-unit/2025/542133) in the Master\'s degree in [Digital humanities and digital knowledge](https://corsi.unibo.it/2cycle/DigitalHumanitiesKnowledge) at the University of Bologna. Announcements: [2022-23](https://bandi.unibo.it/s/aform7/aform-settore-servizi-didattici-lettere-lingue-bando-di-selezione-per-soli-titoli-per-l-attribuzione-di-attivita-di-tutorato-a-a-2022-23-presso-il-dipartimento-di-filologia-classica-e-italianistica/view) | [2025-26](https://bandi.unibo.it/s/aform7/aform-settore-servizi-didattici-lettere-lingue-bando-di-selezione-per-soli-titoli-per-l-attribuzione-a-titolo-oneroso-di-contratti-di-tutorato-didattico-per-i-corsi-di-studio-del-dipartimento-di-filologia-classica-e-italianistica-per-l-a-a-2025-2026/view)'**
  String get tutorDescription;

  /// No description provided for @researchGrantHolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Research grant holder'**
  String get researchGrantHolderTitle;

  /// No description provided for @ficlit.
  ///
  /// In en, this message translates to:
  /// **'Department of Classical Philology and Italian Studies (University of Bologna)'**
  String get ficlit;

  /// No description provided for @researchGrantHolderPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nov 2025 - Present'**
  String get researchGrantHolderPeriod;

  /// No description provided for @researchGrantHolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Extension of OpenCitations technological infrastructure to enable off-line and real-time modifications of bibliographic and citation data collections with provenance and change tracking over time. Funded by [OpenCitations-SCOSS](https://scoss.org/). [Announcement](https://bandi.unibo.it/ricerca/borse-ricerca?id_bando=4891)'**
  String get researchGrantHolderDescription;

  /// No description provided for @researchFellowTitle.
  ///
  /// In en, this message translates to:
  /// **'Research fellow'**
  String get researchFellowTitle;

  /// No description provided for @researchCentreOpenScholarly.
  ///
  /// In en, this message translates to:
  /// **'Research Centre for Open Scholarly Metadata (University of Bologna)'**
  String get researchCentreOpenScholarly;

  /// No description provided for @researchFellowPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nov 2021 - Oct 2022'**
  String get researchFellowPeriod;

  /// No description provided for @researchFellowDescription.
  ///
  /// In en, this message translates to:
  /// **'Involved in the OpenAIRE-Nexus project and developed software to integrate open citations from [OpenCitations](https://opencitations.net/) into the European Open Science Cloud. [Announcement](https://bandi.unibo.it/ricerca/assegni-ricerca?id_bando=58709)'**
  String get researchFellowDescription;

  /// No description provided for @phdCulturalHeritageTitle.
  ///
  /// In en, this message translates to:
  /// **'PhD in cultural heritage in digital ecosystem'**
  String get phdCulturalHeritageTitle;

  /// No description provided for @phdCulturalHeritagePeriod.
  ///
  /// In en, this message translates to:
  /// **'Nov 2022 - Present'**
  String get phdCulturalHeritagePeriod;

  /// No description provided for @phdCulturalHeritageDescription.
  ///
  /// In en, this message translates to:
  /// **'Doctoral research focusing on creating user-friendly interfaces for semantic data, specifically Semantic Web technologies with emphasis on change tracking and provenance. The main focus is [HERITRACE](https://opencitations.github.io/heritrace/), which won the [Gigliozzi Prize](https://www.aiucd.it/premio-gigliozzi-2024/) for best presentation at AIUCD 2024 conference. More info: [PhD program](https://phd.unibo.it/chede/en).'**
  String get phdCulturalHeritageDescription;

  /// No description provided for @phdEngineeringTitle.
  ///
  /// In en, this message translates to:
  /// **'PhD in engineering technology'**
  String get phdEngineeringTitle;

  /// No description provided for @kuLeuven.
  ///
  /// In en, this message translates to:
  /// **'KU Leuven (Belgium)'**
  String get kuLeuven;

  /// No description provided for @phdEngineeringPeriod.
  ///
  /// In en, this message translates to:
  /// **'Mar 2023 - Present'**
  String get phdEngineeringPeriod;

  /// No description provided for @phdEngineeringDescription.
  ///
  /// In en, this message translates to:
  /// **'Joint doctoral program focusing on Knowledge Graph Inversion, extending [RDF Mapping Language (RML)](https://rml.io/) to enable recovery of original data after RDF transformation. More info: [KU Leuven profile](https://www.kuleuven.be/wieiswie/en/person/00170256).'**
  String get phdEngineeringDescription;

  /// No description provided for @unaEuropaPhdTitle.
  ///
  /// In en, this message translates to:
  /// **'Una Europa cultural heritage PhD program'**
  String get unaEuropaPhdTitle;

  /// No description provided for @unaEuropa.
  ///
  /// In en, this message translates to:
  /// **'Una Europa'**
  String get unaEuropa;

  /// No description provided for @unaEuropaPhdPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nov 2023 - Present'**
  String get unaEuropaPhdPeriod;

  /// No description provided for @unaEuropaPhdDescription.
  ///
  /// In en, this message translates to:
  /// **'European consortium doctoral program in cultural heritage studies, providing interdisciplinary research opportunities across multiple universities. More info: [Una Europa HER DOC](https://www.una-europa.eu/study/una-her-doc).'**
  String get unaEuropaPhdDescription;

  /// No description provided for @mastersDegreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Master\'s degree in digital humanities and digital knowledge'**
  String get mastersDegreeTitle;

  /// No description provided for @mastersPeriod.
  ///
  /// In en, this message translates to:
  /// **'Aug 2019 - Nov 2021'**
  String get mastersPeriod;

  /// No description provided for @mastersDescription.
  ///
  /// In en, this message translates to:
  /// **'Graduated summa cum laude (110/110). Thesis: \'[A methodology and an implementation to perform live time-traversal queries on RDF datasets](https://doi.org/10.5281/zenodo.5650879)\'. Developed a methodology for time-traversal queries on RDF datasets, focusing on change tracking and provenance in the Semantic Web.'**
  String get mastersDescription;

  /// No description provided for @bachelorsDegreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s degree in letters - modern curriculum'**
  String get bachelorsDegreeTitle;

  /// No description provided for @bachelorsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Aug 2017 - Nov 2019'**
  String get bachelorsPeriod;

  /// No description provided for @bachelorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Graduated summa cum laude (110/110). Thesis: \'[Valorizzare il sapere digitale: un esperimento di progettazione](https://doi.org/10.5281/zenodo.6623431)\'. Created a digital collection of Italian poetry from the 14th to 20th century, exploring new perspectives for text visualization and analysis.'**
  String get bachelorsDescription;

  /// No description provided for @conferencesAndSeminars.
  ///
  /// In en, this message translates to:
  /// **'Conferences and seminars'**
  String get conferencesAndSeminars;

  /// No description provided for @aiucdConference2024Title.
  ///
  /// In en, this message translates to:
  /// **'AIUCD conference 2024 - Catania'**
  String get aiucdConference2024Title;

  /// No description provided for @aiucdConference2024Period.
  ///
  /// In en, this message translates to:
  /// **'May 28-30, 2024'**
  String get aiucdConference2024Period;

  /// No description provided for @aiucdConference2024Location.
  ///
  /// In en, this message translates to:
  /// **'Catania, Italy'**
  String get aiucdConference2024Location;

  /// No description provided for @aiucdConference2024Description.
  ///
  /// In en, this message translates to:
  /// **'Participated in the Association for Digital Humanities and Digital Culture (AIUCD) conference in Catania with a contribution titled \'HERITRACE: Tracing Evolution and Bridging Data for Streamlined Curatorial Work in the GLAM Domain\'. [Conference](https://aiucd2024.unict.it/) | [Paper](https://doi.org/10.6092/issn.2532-8816/21218) | [Presentation](https://zenodo.org/doi/10.5281/zenodo.11474571)'**
  String get aiucdConference2024Description;

  /// No description provided for @cziHackathon2023Title.
  ///
  /// In en, this message translates to:
  /// **'Hackathon \'Mapping the Impact of Research Software in Science\''**
  String get cziHackathon2023Title;

  /// No description provided for @cziHackathon2023Period.
  ///
  /// In en, this message translates to:
  /// **'Oct 24-27, 2023'**
  String get cziHackathon2023Period;

  /// No description provided for @cziHackathon2023Location.
  ///
  /// In en, this message translates to:
  /// **'Redwood City, California, USA'**
  String get cziHackathon2023Location;

  /// No description provided for @cziHackathon2023Description.
  ///
  /// In en, this message translates to:
  /// **'Participated in the hackathon hosted by Chan Zuckerberg Initiative, focusing on integrating data models from three software mention collections: SoMeSci, Softcite and RRID. Created a mapping table that served as a starting point for creating a \'gold dataset\' aimed at improving software mention extraction in scientific literature. [Repository](https://github.com/chanzuckerberg/software-impact-hackathon-2023)'**
  String get cziHackathon2023Description;

  /// No description provided for @adhoDhConf2023Title.
  ///
  /// In en, this message translates to:
  /// **'ADHO Digital Humanities conferences 2023 in Graz'**
  String get adhoDhConf2023Title;

  /// No description provided for @adhoDhConf2023Period.
  ///
  /// In en, this message translates to:
  /// **'Jul 10-15, 2023'**
  String get adhoDhConf2023Period;

  /// No description provided for @adhoDhConf2023Location.
  ///
  /// In en, this message translates to:
  /// **'Graz, Austria'**
  String get adhoDhConf2023Location;

  /// No description provided for @adhoDhConf2023Description.
  ///
  /// In en, this message translates to:
  /// **'Participated in the ADHO Digital Humanities conferences 2023 with a contribution titled \'Representing provenance and track changes of cultural heritage metadata in RDF: a survey of existing approaches\'. [Conference](https://dh2023.adho.org/) | [Paper](https://doi.org/10.1093/llc/fqaf076) | [Presentation](https://doi.org/10.5281/zenodo.8153979)'**
  String get adhoDhConf2023Description;

  /// No description provided for @rdaPlenary2023Title.
  ///
  /// In en, this message translates to:
  /// **'20th Research Data Alliance plenary meeting in Göteborg'**
  String get rdaPlenary2023Title;

  /// No description provided for @rdaPlenary2023Period.
  ///
  /// In en, this message translates to:
  /// **'Mar 21-23, 2023'**
  String get rdaPlenary2023Period;

  /// No description provided for @rdaPlenary2023Location.
  ///
  /// In en, this message translates to:
  /// **'Göteborg, Sweden'**
  String get rdaPlenary2023Location;

  /// No description provided for @rdaPlenary2023Description.
  ///
  /// In en, this message translates to:
  /// **'Participated in the 20th plenary meeting of the Research Data Alliance with a contribution titled \'Adopting the Scientific Knowledge Graphs Interoperability Framework in OpenCitations\'. [Conference](https://faircore4eosc.eu/events/rda-20th-plenary-meeting-gothenburg-hybrid) | [Presentation](https://doi.org/10.5281/zenodo.7702070)'**
  String get rdaPlenary2023Description;

  /// No description provided for @csvconfV9Conference2025Title.
  ///
  /// In en, this message translates to:
  /// **'csv,conf,v9 - Bologna'**
  String get csvconfV9Conference2025Title;

  /// No description provided for @csvconfV9Conference2025Period.
  ///
  /// In en, this message translates to:
  /// **'Sep 8-11, 2025'**
  String get csvconfV9Conference2025Period;

  /// No description provided for @csvconfV9Conference2025Location.
  ///
  /// In en, this message translates to:
  /// **'Bologna, Italy'**
  String get csvconfV9Conference2025Location;

  /// No description provided for @csvconfV9Conference2025Description.
  ///
  /// In en, this message translates to:
  /// **'Participated in csv,conf,v9, a community conference for data makers everywhere with the theme \'Data for Communities\'. Presented \'Mapping the unmapped citation landscape: how crowdsourcing will fill the citation gap\', discussing how to democratize the citation landscape by connecting 41,500 Global South journals and introducing millions of new citations through a collaborative solution between OpenCitations, Public Knowledge Project (PKP), and Leibniz Information Centre. [Conference](https://csvconf.com/) | [Presentation](https://doi.org/10.5281/zenodo.17098599)'**
  String get csvconfV9Conference2025Description;

  /// No description provided for @unaEuropaWorkshop2025Title.
  ///
  /// In en, this message translates to:
  /// **'Una Europa PhD workshop - \'Museums and the new challenges\''**
  String get unaEuropaWorkshop2025Title;

  /// No description provided for @unaEuropaWorkshop2025Period.
  ///
  /// In en, this message translates to:
  /// **'May 5-10, 2025'**
  String get unaEuropaWorkshop2025Period;

  /// No description provided for @unaEuropaWorkshop2025Location.
  ///
  /// In en, this message translates to:
  /// **'Bologna, Italy'**
  String get unaEuropaWorkshop2025Location;

  /// No description provided for @unaEuropaWorkshop2025Description.
  ///
  /// In en, this message translates to:
  /// **'Participation in the Una Europa transdisciplinary workshop for PhD students focused on \'Museums and the new challenges: virtual technologies, societal responsibility and environmental sustainability\'. Presentation titled \'HERITRACE: A User-Friendly Semantic Data Editor with Change Tracking and Provenance Management for Cultural Heritage Institutions\'. [Workshop info](https://site.unibo.it/una-europa/en/focus-areas/una-her-doc-una-europa-phd-workshop) | [Presentation](https://doi.org/10.5281/zenodo.15375770)'**
  String get unaEuropaWorkshop2025Description;

  /// No description provided for @astroGodsTitle.
  ///
  /// In en, this message translates to:
  /// **'~~Against~~ Beyond Science'**
  String get astroGodsTitle;

  /// No description provided for @astroGodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Astrology and artificial intelligence'**
  String get astroGodsSubtitle;

  /// No description provided for @astroGodsIntroduction.
  ///
  /// In en, this message translates to:
  /// **'In my free time I work on AstroGods, a project that applies artificial intelligence to astrological interpretations.'**
  String get astroGodsIntroduction;

  /// No description provided for @astroGodsCard1Title.
  ///
  /// In en, this message translates to:
  /// **'A complex problem'**
  String get astroGodsCard1Title;

  /// No description provided for @astroGodsCard1Description.
  ///
  /// In en, this message translates to:
  /// **'Astrological interpretations done well (not those for entertainment) are incredibly complex. They must symbolically unite infinite elements.'**
  String get astroGodsCard1Description;

  /// No description provided for @astroGodsCard2Title.
  ///
  /// In en, this message translates to:
  /// **'Infinite elements'**
  String get astroGodsCard2Title;

  /// No description provided for @astroGodsCard2Description.
  ///
  /// In en, this message translates to:
  /// **'Planetary positions in houses and signs, the aspects they form with each other. Each element adds layers of symbolic meaning.'**
  String get astroGodsCard2Description;

  /// No description provided for @astroGodsCard3Title.
  ///
  /// In en, this message translates to:
  /// **'Exponential complexity'**
  String get astroGodsCard3Title;

  /// No description provided for @astroGodsCard3Description.
  ///
  /// In en, this message translates to:
  /// **'Complexity grows exponentially when comparing different charts: two people, a person and a specific moment, or why not, entire social groups.'**
  String get astroGodsCard3Description;

  /// No description provided for @astroGodsCard4Title.
  ///
  /// In en, this message translates to:
  /// **'Egyptian tradition'**
  String get astroGodsCard4Title;

  /// No description provided for @astroGodsCard4Description.
  ///
  /// In en, this message translates to:
  /// **'AstroGods uses the Egyptian astrological tradition and the equal-area house system (Vehlow system) as methodological foundation.'**
  String get astroGodsCard4Description;

  /// No description provided for @astroGodsCard5Title.
  ///
  /// In en, this message translates to:
  /// **'Artificial intelligence'**
  String get astroGodsCard5Title;

  /// No description provided for @astroGodsCard5Description.
  ///
  /// In en, this message translates to:
  /// **'AI connects all pieces of the astrological puzzle to find hidden connections and generate complete interpretations.'**
  String get astroGodsCard5Description;

  /// No description provided for @astroGodsCard6Title.
  ///
  /// In en, this message translates to:
  /// **'Nosce te ipsum'**
  String get astroGodsCard6Title;

  /// No description provided for @astroGodsCard6Description.
  ///
  /// In en, this message translates to:
  /// **'Preliminary analyses accessible to both laypeople and experts as starting points for personal reflection.'**
  String get astroGodsCard6Description;

  /// No description provided for @astroGodsVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get astroGodsVisitWebsite;

  /// No description provided for @astroGodsGetOnFlathub.
  ///
  /// In en, this message translates to:
  /// **'Flathub'**
  String get astroGodsGetOnFlathub;

  /// No description provided for @astroGodsGetOnSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap Store'**
  String get astroGodsGetOnSnap;

  /// No description provided for @astroGodsCollaborate.
  ///
  /// In en, this message translates to:
  /// **'Collaborate with me'**
  String get astroGodsCollaborate;

  /// No description provided for @astroGodsIframeHidden.
  ///
  /// In en, this message translates to:
  /// **'Iframe hidden during language change'**
  String get astroGodsIframeHidden;

  /// No description provided for @astroGodsVisitForFullExperience.
  ///
  /// In en, this message translates to:
  /// **'Visit the website for the full experience'**
  String get astroGodsVisitForFullExperience;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get tableOfContents;

  /// No description provided for @downloadCV.
  ///
  /// In en, this message translates to:
  /// **'Download CV'**
  String get downloadCV;

  /// No description provided for @downloadingCV.
  ///
  /// In en, this message translates to:
  /// **'Generating CV...'**
  String get downloadingCV;

  /// No description provided for @cvGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'CV generated successfully'**
  String get cvGeneratedSuccessfully;

  /// No description provided for @cvEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'EDUCATION AND TRAINING'**
  String get cvEducationTitle;

  /// No description provided for @cvWorkExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'WORK EXPERIENCE'**
  String get cvWorkExperienceTitle;

  /// No description provided for @cvConferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'CONFERENCES AND SEMINARS'**
  String get cvConferencesTitle;

  /// No description provided for @cvSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'SKILLS'**
  String get cvSkillsTitle;

  /// No description provided for @cvPublicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'PUBLICATIONS'**
  String get cvPublicationsTitle;

  /// No description provided for @cvOtherPublications.
  ///
  /// In en, this message translates to:
  /// **'OTHER PUBLICATIONS'**
  String get cvOtherPublications;

  /// No description provided for @cvDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth:'**
  String get cvDateOfBirth;

  /// No description provided for @cvNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality:'**
  String get cvNationality;

  /// No description provided for @cvAddress.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get cvAddress;

  /// No description provided for @cvNationalityValue.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get cvNationalityValue;

  /// No description provided for @cvBirthDate.
  ///
  /// In en, this message translates to:
  /// **'August 23, 1997'**
  String get cvBirthDate;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @flutterAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Made with Flutter'**
  String get flutterAppTitle;

  /// No description provided for @flutterAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install as an app too'**
  String get flutterAppSubtitle;

  /// No description provided for @flutterAppDescription.
  ///
  /// In en, this message translates to:
  /// **'This portfolio is built with Flutter, which means you can download it as a native app for Android, iOS, Windows, macOS and Linux, or install it as a Progressive Web App. Why would you want my portfolio as an installable app? I have no idea, but it\'s pretty cool'**
  String get flutterAppDescription;

  /// No description provided for @downloadForAndroid.
  ///
  /// In en, this message translates to:
  /// **'Download for Android'**
  String get downloadForAndroid;

  /// No description provided for @downloadForIOS.
  ///
  /// In en, this message translates to:
  /// **'Download for iOS'**
  String get downloadForIOS;

  /// No description provided for @downloadForWindows.
  ///
  /// In en, this message translates to:
  /// **'Download for Windows'**
  String get downloadForWindows;

  /// No description provided for @downloadForMacOS.
  ///
  /// In en, this message translates to:
  /// **'Download for macOS'**
  String get downloadForMacOS;

  /// No description provided for @downloadForLinux.
  ///
  /// In en, this message translates to:
  /// **'Download for Linux'**
  String get downloadForLinux;

  /// No description provided for @viewSourceCode.
  ///
  /// In en, this message translates to:
  /// **'View source code'**
  String get viewSourceCode;

  /// No description provided for @installationInstructions.
  ///
  /// In en, this message translates to:
  /// **'For installation instructions, check the README on GitHub'**
  String get installationInstructions;

  /// No description provided for @closeFlutterInfo.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get closeFlutterInfo;

  /// No description provided for @profileImageAlt.
  ///
  /// In en, this message translates to:
  /// **'Arcangelo Massari\'s professional photo'**
  String get profileImageAlt;

  /// No description provided for @openCitationsLogoAlt.
  ///
  /// In en, this message translates to:
  /// **'OpenCitations logo'**
  String get openCitationsLogoAlt;

  /// No description provided for @lightModeIconAlt.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get lightModeIconAlt;

  /// No description provided for @darkModeIconAlt.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get darkModeIconAlt;

  /// No description provided for @orbitingPlanetAlt.
  ///
  /// In en, this message translates to:
  /// **'Decorative orbiting element'**
  String get orbitingPlanetAlt;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @faqResearchQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your research about?'**
  String get faqResearchQuestion;

  /// No description provided for @faqResearchAnswer.
  ///
  /// In en, this message translates to:
  /// **'My research focuses on creating user-friendly interfaces for semantic data in cultural heritage. I work on [HERITRACE](https://opencitations.github.io/heritrace/), a tool that helps cultural heritage institutions manage metadata with change tracking and provenance, making complex semantic web technologies accessible to curators and researchers.'**
  String get faqResearchAnswer;

  /// No description provided for @faqTechnicalQuestion.
  ///
  /// In en, this message translates to:
  /// **'What technologies do you work with?'**
  String get faqTechnicalQuestion;

  /// No description provided for @faqTechnicalAnswer.
  ///
  /// In en, this message translates to:
  /// **'I primarily work with Semantic Web technologies like RDF, SPARQL, and various triple stores. For development, I use Python, JavaScript/TypeScript, and Flutter.'**
  String get faqTechnicalAnswer;

  /// No description provided for @faqContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s the best way to contact you?'**
  String get faqContactQuestion;

  /// No description provided for @faqContactAnswer.
  ///
  /// In en, this message translates to:
  /// **'Email is usually the best way to reach me at [arcangelo.massari@unibo.it](mailto:arcangelo.massari@unibo.it). You can also find me on [LinkedIn](https://www.linkedin.com/in/arcangelo-massari-4a736822b/), [GitHub](https://github.com/arcangelo7), or visit my [institutional page](https://www.unibo.it/sitoweb/arcangelo.massari/en) at the University of Bologna. I\'m responsive and always happy to discuss research or answer questions about my work.'**
  String get faqContactAnswer;

  /// No description provided for @europassHeader.
  ///
  /// In en, this message translates to:
  /// **'Curriculum Vitae\nEuropass'**
  String get europassHeader;

  /// No description provided for @europassPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get europassPersonalInfo;

  /// No description provided for @europassName.
  ///
  /// In en, this message translates to:
  /// **'Name and surname'**
  String get europassName;

  /// No description provided for @europassWorkExperience.
  ///
  /// In en, this message translates to:
  /// **'Work experience'**
  String get europassWorkExperience;

  /// No description provided for @europassDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get europassDates;

  /// No description provided for @europassPosition.
  ///
  /// In en, this message translates to:
  /// **'Job or position held'**
  String get europassPosition;

  /// No description provided for @europassEmployer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get europassEmployer;

  /// No description provided for @europassActivities.
  ///
  /// In en, this message translates to:
  /// **'Main activities and responsibilities'**
  String get europassActivities;

  /// No description provided for @europassEducation.
  ///
  /// In en, this message translates to:
  /// **'Education and training'**
  String get europassEducation;

  /// No description provided for @europassQualification.
  ///
  /// In en, this message translates to:
  /// **'Title of qualification awarded'**
  String get europassQualification;

  /// No description provided for @europassInstitution.
  ///
  /// In en, this message translates to:
  /// **'Name and type of organization providing education and training'**
  String get europassInstitution;

  /// No description provided for @europassSubjects.
  ///
  /// In en, this message translates to:
  /// **'Main subjects/occupational skills covered'**
  String get europassSubjects;

  /// No description provided for @europassPersonalSkills.
  ///
  /// In en, this message translates to:
  /// **'Personal skills'**
  String get europassPersonalSkills;

  /// No description provided for @europassMotherTongue.
  ///
  /// In en, this message translates to:
  /// **'Mother tongue'**
  String get europassMotherTongue;

  /// No description provided for @europassOtherLanguages.
  ///
  /// In en, this message translates to:
  /// **'Other language(s)'**
  String get europassOtherLanguages;

  /// No description provided for @europassListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get europassListening;

  /// No description provided for @europassReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get europassReading;

  /// No description provided for @europassSpokenInteraction.
  ///
  /// In en, this message translates to:
  /// **'Spoken interaction'**
  String get europassSpokenInteraction;

  /// No description provided for @europassSpokenProduction.
  ///
  /// In en, this message translates to:
  /// **'Spoken production'**
  String get europassSpokenProduction;

  /// No description provided for @europassWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get europassWriting;

  /// No description provided for @europassCefrReference.
  ///
  /// In en, this message translates to:
  /// **'Common European Framework of Reference for Languages'**
  String get europassCefrReference;

  /// No description provided for @europassTechnicalSkills.
  ///
  /// In en, this message translates to:
  /// **'Technical and IT skills'**
  String get europassTechnicalSkills;

  /// No description provided for @europassDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving license'**
  String get europassDrivingLicense;

  /// No description provided for @europassLicenseB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get europassLicenseB;

  /// No description provided for @europassGdprConsent.
  ///
  /// In en, this message translates to:
  /// **'I authorize the processing of the personal data contained in my curriculum vitae pursuant to art. 13 of Legislative Decree 196/2003 and art. 13 of EU Regulation 2016/679 relating to the protection of natural persons with regard to the processing of personal data.'**
  String get europassGdprConsent;

  /// No description provided for @languagesItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languagesItalian;

  /// No description provided for @languagesEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languagesEnglish;

  /// No description provided for @exportCVEuropass.
  ///
  /// In en, this message translates to:
  /// **'Export CV Europass'**
  String get exportCVEuropass;

  /// No description provided for @cvDownloadDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Download my CV'**
  String get cvDownloadDialogTitle;

  /// No description provided for @cvDownloadMyWay.
  ///
  /// In en, this message translates to:
  /// **'My way'**
  String get cvDownloadMyWay;

  /// No description provided for @cvDownloadOfficeWay.
  ///
  /// In en, this message translates to:
  /// **'Office-friendly'**
  String get cvDownloadOfficeWay;
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
