// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Portfolio di Arcangelo Massari';

  @override
  String get name => 'Arcangelo Massari';

  @override
  String get jobTitle => 'Dottorando in Digital Humanities';

  @override
  String get viewMyWork => 'Dai un\'occhiata ai miei progetti';

  @override
  String get aboutMe => 'Chi Sono';

  @override
  String get aboutMeDescription =>
      'Sto facendo il dottorato tra l\'Università di Bologna e KU Leuven, lavorando su Digital Humanities e patrimonio culturale digitale. La mia ricerca si concentra sulla creazione di interfacce user-friendly per dati semantici, specificamente tecnologie del Web Semantico con focus su change tracking e provenance. Ho vinto il [Premio Gigliozzi](https://www.aiucd.it/premio-gigliozzi-2024/) per la miglior presentazione alla conferenza AIUCD con [HERITRACE](https://opencitations.github.io/heritrace/), che è il focus principale del mio lavoro di dottorato.';

  @override
  String get skills => 'Competenze';

  @override
  String get getInTouch => 'Contattami';

  @override
  String get copyright => '© 2025 Arcangelo. Tutti i diritti riservati.';

  @override
  String get skillFlutter => 'Flutter';

  @override
  String get skillDart => 'Dart';

  @override
  String get skillJavaScript => 'JavaScript';

  @override
  String get skillPython => 'Python';

  @override
  String get skillUIUX => 'Design UI/UX';

  @override
  String get publications => 'Pubblicazioni';

  @override
  String get loadingPublications => 'Caricamento pubblicazioni...';

  @override
  String get noPublications => 'Nessuna pubblicazione disponibile';

  @override
  String get viewDoi => 'Visualizza DOI';

  @override
  String get viewUrl => 'Visualizza Articolo';

  @override
  String get viewPaper => 'Visualizza Paper';

  @override
  String get viewBook => 'Visualizza Libro';

  @override
  String get viewChapter => 'Visualizza Capitolo';

  @override
  String get viewSoftware => 'Visualizza Software';

  @override
  String get viewPresentation => 'Visualizza Presentazione';

  @override
  String get publicationsDescription =>
      'Le mie ricerche pubblicate e lavori accademici';

  @override
  String get categoryAll => 'Tutte';

  @override
  String get categoryJournalArticle => 'Articolo di Rivista';

  @override
  String get categoryConferencePaper => 'Paper di Conferenza';

  @override
  String get categoryBook => 'Libro';

  @override
  String get categoryBookSection => 'Capitolo di Libro';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryPresentation => 'Presentazione';

  @override
  String get categoryThesis => 'Tesi';

  @override
  String get categoryReport => 'Report';

  @override
  String get categoryOther => 'Altro';

  @override
  String get noPublicationsForCategory =>
      'Nessuna pubblicazione trovata per la categoria selezionata';

  @override
  String get showAllAuthors => 'Mostra tutti gli autori';

  @override
  String get showLess => 'Mostra meno';

  @override
  String andMoreAuthors(Object count) {
    return 'e altri $count...';
  }

  @override
  String get abstract => 'Abstract';

  @override
  String get readMore => 'Leggi di più';

  @override
  String get previousPage => 'Pagina precedente';

  @override
  String get nextPage => 'Pagina successiva';
}
