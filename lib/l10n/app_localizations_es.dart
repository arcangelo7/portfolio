// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Portfolio de Arcangelo Massari';

  @override
  String get name => 'Arcangelo Massari';

  @override
  String get jobTitle => 'Candidato a PhD en Humanidades Digitales';

  @override
  String get viewMyWork => 'Ver Mi Trabajo';

  @override
  String get aboutMe => 'Sobre Mí';

  @override
  String get aboutMeDescription =>
      'Soy candidato a PhD en la Universidad de Bolonia y KU Leuven, especializado en Humanidades Digitales y patrimonio cultural digital. Mi investigación se centra en Web Semántica, metadatos bibliográficos y OpenCitations. Gané el Premio Gigliozzi 2024 por la mejor contribución en informática humanística.';

  @override
  String get skills => 'Habilidades';

  @override
  String get getInTouch => 'Ponte en Contacto';

  @override
  String get copyright =>
      '© 2025 Arcangelo Massari. Todos los derechos reservados.';

  @override
  String get skillFlutter => 'Flutter';

  @override
  String get skillDart => 'Dart';

  @override
  String get skillJavaScript => 'JavaScript';

  @override
  String get skillPython => 'Python';

  @override
  String get skillUIUX => 'Diseño UI/UX';

  @override
  String get publications => 'Publicaciones';

  @override
  String get loadingPublications => 'Cargando publicaciones...';

  @override
  String get noPublications => 'No hay publicaciones disponibles';

  @override
  String get viewDoi => 'Ver DOI';

  @override
  String get viewUrl => 'Ver Artículo';

  @override
  String get viewPaper => 'Ver Paper';

  @override
  String get viewBook => 'Ver Libro';

  @override
  String get viewChapter => 'Ver Capítulo';

  @override
  String get viewSoftware => 'Ver Software';

  @override
  String get viewPresentation => 'Ver Presentación';

  @override
  String get publicationsDescription =>
      'Publicaciones académicas seleccionadas y contribuciones de investigación';

  @override
  String get categoryAll => 'Todas';

  @override
  String get categoryJournalArticle => 'Artículo de Revista';

  @override
  String get categoryConferencePaper => 'Paper de Conferencia';

  @override
  String get categoryBook => 'Libro';

  @override
  String get categoryBookSection => 'Capítulo de Libro';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryPresentation => 'Presentación';

  @override
  String get categoryOther => 'Otro';

  @override
  String get noPublicationsForCategory =>
      'No se encontraron publicaciones para la categoría seleccionada';

  @override
  String get showAllAuthors => 'Mostrar todos los autores';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String andMoreAuthors(Object count) {
    return 'y $count más...';
  }

  @override
  String get abstract => 'Abstract';

  @override
  String get readMore => 'Leer más';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Página siguiente';
}
