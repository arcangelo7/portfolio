import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../models/cv_data.dart';
import '../services/zotero_service.dart';
import '../services/cv_data_service.dart';
import '../main.dart';

class DynamicCVGeneratorService {
  static String _getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      case 'jobTitle':
        return l10n.jobTitle;
      case 'cvBirthDate':
        return l10n.cvBirthDate;
      case 'cvNationalityValue':
        return l10n.cvNationalityValue;
      case 'phdCulturalHeritageTitle':
        return l10n.phdCulturalHeritageTitle;
      case 'phdCulturalHeritagePeriod':
        return l10n.phdCulturalHeritagePeriod;
      case 'phdCulturalHeritageDescription':
        return l10n.phdCulturalHeritageDescription;
      case 'phdEngineeringTitle':
        return l10n.phdEngineeringTitle;
      case 'phdEngineeringPeriod':
        return l10n.phdEngineeringPeriod;
      case 'phdEngineeringDescription':
        return l10n.phdEngineeringDescription;
      case 'mastersDegreeTitle':
        return l10n.mastersDegreeTitle;
      case 'mastersPeriod':
        return l10n.mastersPeriod;
      case 'mastersDescription':
        return l10n.mastersDescription;
      case 'bachelorsDegreeTitle':
        return l10n.bachelorsDegreeTitle;
      case 'bachelorsPeriod':
        return l10n.bachelorsPeriod;
      case 'bachelorsDescription':
        return l10n.bachelorsDescription;
      case 'universityBologna':
        return l10n.universityBologna;
      case 'kuLeuven':
        return l10n.kuLeuven;
      case 'tutorTitle':
        return l10n.tutorTitle;
      case 'tutorPeriod':
        return l10n.tutorPeriod;
      case 'tutorDescription':
        return l10n.tutorDescription;
      case 'researchFellowTitle':
        return l10n.researchFellowTitle;
      case 'researchFellowPeriod':
        return l10n.researchFellowPeriod;
      case 'researchFellowDescription':
        return l10n.researchFellowDescription;
      case 'researchCentreOpenScholarly':
        return l10n.researchCentreOpenScholarly;
      case 'aiucdConference2024Title':
        return l10n.aiucdConference2024Title;
      case 'aiucdConference2024Period':
        return l10n.aiucdConference2024Period;
      case 'aiucdConference2024Location':
        return l10n.aiucdConference2024Location;
      case 'aiucdConference2024Description':
        return l10n.aiucdConference2024Description;
      case 'cziHackathon2023Title':
        return l10n.cziHackathon2023Title;
      case 'cziHackathon2023Period':
        return l10n.cziHackathon2023Period;
      case 'cziHackathon2023Location':
        return l10n.cziHackathon2023Location;
      case 'cziHackathon2023Description':
        return l10n.cziHackathon2023Description;
      case 'adhoDhConf2023Title':
        return l10n.adhoDhConf2023Title;
      case 'adhoDhConf2023Period':
        return l10n.adhoDhConf2023Period;
      case 'adhoDhConf2023Location':
        return l10n.adhoDhConf2023Location;
      case 'adhoDhConf2023Description':
        return l10n.adhoDhConf2023Description;
      case 'rdaPlenary2023Title':
        return l10n.rdaPlenary2023Title;
      case 'rdaPlenary2023Period':
        return l10n.rdaPlenary2023Period;
      case 'rdaPlenary2023Location':
        return l10n.rdaPlenary2023Location;
      case 'rdaPlenary2023Description':
        return l10n.rdaPlenary2023Description;
      case 'unaEuropaWorkshop2025Title':
        return l10n.unaEuropaWorkshop2025Title;
      case 'unaEuropaWorkshop2025Period':
        return l10n.unaEuropaWorkshop2025Period;
      case 'unaEuropaWorkshop2025Location':
        return l10n.unaEuropaWorkshop2025Location;
      case 'unaEuropaWorkshop2025Description':
        return l10n.unaEuropaWorkshop2025Description;
      case 'skillCategoryProgrammingLanguages':
        return l10n.skillCategoryProgrammingLanguages;
      case 'skillCategoryMarkupAndTemplating':
        return l10n.skillCategoryMarkupAndTemplating;
      case 'skillCategoryStylingAndDesign':
        return l10n.skillCategoryStylingAndDesign;
      case 'skillCategoryQueryAndTransform':
        return l10n.skillCategoryQueryAndTransform;
      case 'skillCategorySemanticWebAndRDF':
        return l10n.skillCategorySemanticWebAndRDF;
      case 'skillCategoryFrontendLibraries':
        return l10n.skillCategoryFrontendLibraries;
      case 'skillCategoryBackendFrameworks':
        return l10n.skillCategoryBackendFrameworks;
      case 'skillCategoryDatabases':
        return l10n.skillCategoryDatabases;
      case 'skillCategoryInfrastructureDevOps':
        return l10n.skillCategoryInfrastructureDevOps;
      case 'skillCategoryOperatingSystems':
        return l10n.skillCategoryOperatingSystems;
      case 'skillPython':
        return l10n.skillPython;
      case 'skillJavaScript':
        return l10n.skillJavaScript;
      case 'skillTypeScript':
        return l10n.skillTypeScript;
      case 'skillDart':
        return l10n.skillDart;
      case 'skillHTML':
        return l10n.skillHTML;
      case 'skillXML':
        return l10n.skillXML;
      case 'skillTEI':
        return l10n.skillTEI;
      case 'skillCSS':
        return l10n.skillCSS;
      case 'skillSASS':
        return l10n.skillSASS;
      case 'skillBootstrap':
        return l10n.skillBootstrap;
      case 'skillSPARQL':
        return l10n.skillSPARQL;
      case 'skillSQL':
        return l10n.skillSQL;
      case 'skillXPath':
        return l10n.skillXPath;
      case 'skillXQuery':
        return l10n.skillXQuery;
      case 'skillXSLT':
        return l10n.skillXSLT;
      case 'skillRDF':
        return l10n.skillRDF;
      case 'skillSHACL':
        return l10n.skillSHACL;
      case 'skillApacheJenaFuseki':
        return l10n.skillApacheJenaFuseki;
      case 'skillGraphDB':
        return l10n.skillGraphDB;
      case 'skillBlazeGraph':
        return l10n.skillBlazeGraph;
      case 'skillOpenLinkVirtuoso':
        return l10n.skillOpenLinkVirtuoso;
      case 'skillReact':
        return l10n.skillReact;
      case 'skillD3JS':
        return l10n.skillD3JS;
      case 'skillFlutter':
        return l10n.skillFlutter;
      case 'skillNodeJS':
        return l10n.skillNodeJS;
      case 'skillFlask':
        return l10n.skillFlask;
      case 'skillPrisma':
        return l10n.skillPrisma;
      case 'skillMongoDB':
        return l10n.skillMongoDB;
      case 'skillPostgreSQL':
        return l10n.skillPostgreSQL;
      case 'skillRedis':
        return l10n.skillRedis;
      case 'skillDocker':
        return l10n.skillDocker;
      case 'skillProxmox':
        return l10n.skillProxmox;
      case 'skillGitHubActions':
        return l10n.skillGitHubActions;
      case 'skillDebian':
        return l10n.skillDebian;
      case 'skillFedora':
        return l10n.skillFedora;
      default:
        return key;
    }
  }

  static PdfColor _convertFlutterToPdfColor(Color flutterColor) {
    return PdfColor(
      (flutterColor.r * 255.0).round() / 255.0,
      (flutterColor.g * 255.0).round() / 255.0,
      (flutterColor.b * 255.0).round() / 255.0,
      flutterColor.a,
    );
  }

  static String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('www.')) {
        return 'https://$url';
      } else if (url.contains('@')) {
        return 'mailto:$url';
      } else {
        return 'https://$url';
      }
    }
    return url;
  }

  static Future<pw.ThemeData> _createUnicodeTheme() async {
    final dejaVuRegular = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DejaVuSans-Regular.ttf"),
    );
    final dejaVuBold = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DejaVuSans-Bold.ttf"),
    );
    final dejaVuItalic = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DejaVuSans-Italic.ttf"),
    );
    final dejaVuBoldItalic = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DejaVuSans-BoldItalic.ttf"),
    );

    return pw.ThemeData.withFont(
      base: dejaVuRegular,
      bold: dejaVuBold,
      italic: dejaVuItalic,
      boldItalic: dejaVuBoldItalic,
    );
  }

  static pw.Widget _buildRichText(String text, {double fontSize = 9}) {
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return pw.Text(text, style: pw.TextStyle(fontSize: fontSize));
    }

    final List<pw.InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before the link
      if (match.start > lastMatchEnd) {
        spans.add(
          pw.TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: pw.TextStyle(fontSize: fontSize),
          ),
        );
      }

      // Add the clickable link
      final linkText = match.group(1) ?? '';
      var linkUrl = _normalizeUrl(match.group(2) ?? '');

      spans.add(
        pw.TextSpan(
          text: linkText,
          style: pw.TextStyle(
            fontSize: fontSize,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(linkUrl),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last link
    if (lastMatchEnd < text.length) {
      spans.add(
        pw.TextSpan(
          text: text.substring(lastMatchEnd),
          style: pw.TextStyle(fontSize: fontSize),
        ),
      );
    }

    return pw.RichText(text: pw.TextSpan(children: spans));
  }

  static Future<Uint8List> generateCV(
    AppLocalizations l10n, {
    ZoteroService? zoteroService,
  }) async {
    final theme = await _createUnicodeTheme();
    final pdf = pw.Document(theme: theme);

    List<Publication> publications = [];
    if (zoteroService != null) {
      try {
        publications = await zoteroService.getPublications();
        publications.sort((a, b) => b.displayYear.compareTo(a.displayYear));
      } catch (e) {
        // If publications fail to load, continue without them
      }
    }

    final cvData = await CVDataService.loadCVData();

    final headerColor = _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue);
    final sectionColor = _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue.withValues(alpha: 0.8));
    final lightBlue = _convertFlutterToPdfColor(PortfolioTheme.iceWhite);

    final header = await _buildHeader(headerColor, l10n, cvData.personalInfo);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 20,
        build: (pw.Context context) {
          return [
            header,
            pw.SizedBox(height: 20),
            _buildPersonalInfo(l10n, cvData.personalInfo),
            pw.SizedBox(height: 20),
            _buildSection(
              l10n.cvEducationTitle,
              _buildEducationContent(l10n, cvData.education),
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 15),
            _buildSection(
              l10n.cvWorkExperienceTitle,
              _buildWorkExperienceContent(l10n, cvData.workExperience),
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 15),
            _buildSection(
              l10n.cvConferencesTitle,
              _buildConferencesContent(l10n, cvData.conferences),
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 15),
            _buildSection(
              l10n.cvSkillsTitle,
              _buildSkillsContent(l10n, cvData.skills),
              sectionColor,
              lightBlue,
            ),
            if (publications.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              _buildSectionHeader(
                l10n.cvPublicationsTitle,
                sectionColor,
                lightBlue,
              ),
              pw.SizedBox(height: 10),
              ..._buildPublications(publications, l10n),
            ],
            pw.SizedBox(height: 20),
            _buildFooter(l10n),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static String _getCategoryDisplayName(
    String categoryKey,
    AppLocalizations l10n,
  ) {
    switch (categoryKey) {
      case 'journalArticle':
        return l10n.categoryJournalArticle;
      case 'conferencePaper':
        return l10n.categoryConferencePaper;
      case 'bookSection':
        return l10n.categoryBookSection;
      case 'computerProgram':
        return l10n.categorySoftware;
      case 'presentation':
        return l10n.categoryPresentation;
      case 'thesis':
        return l10n.categoryThesis;
      case 'report':
        return l10n.categoryReport;
      default:
        return categoryKey;
    }
  }

  /// Get the ordered list of publication categories by importance
  static List<String> _getCategoryOrder() {
    return [
      'journalArticle',
      'conferencePaper',
      'bookSection',
      'thesis',
      'presentation',
      'report',
      'computerProgram',
    ];
  }

  /// Group publications by category and return them in order of importance
  static Map<String, List<Publication>> _groupPublicationsByCategory(
    List<Publication> publications,
  ) {
    final Map<String, List<Publication>> grouped = {};
    final categoryOrder = _getCategoryOrder();

    // Initialize groups for all categories
    for (final category in categoryOrder) {
      grouped[category] = [];
    }

    // Group publications by category
    for (final publication in publications) {
      final category = publication.itemType;
      if (grouped.containsKey(category)) {
        grouped[category]!.add(publication);
      } else {
        // For unknown categories, add them to a separate list
        grouped.putIfAbsent('other', () => []).add(publication);
      }
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  static Future<pw.Widget> _buildHeader(PdfColor headerColor, AppLocalizations l10n, PersonalInfo personalInfo) async {
    final imageBytes = await rootBundle.load(personalInfo.photoPath);
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    
    final photoWidget = pw.Container(
      width: 80,
      height: 80,
      child: pw.Image(image, fit: pw.BoxFit.contain),
    );

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(color: headerColor),
      padding: const pw.EdgeInsets.all(20),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  personalInfo.name,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  _getLocalizedText(l10n, personalInfo.jobTitleKey),
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          photoWidget,
        ],
      ),
    );
  }

  static pw.Widget _buildPersonalInfo(AppLocalizations l10n, PersonalInfo personalInfo) {
    final personalData = [
      {'label': l10n.cvDateOfBirth, 'value': _getLocalizedText(l10n, personalInfo.birthDateKey)},
      {'label': l10n.cvNationality, 'value': _getLocalizedText(l10n, personalInfo.nationalityKey)},
      {'label': 'Email:', 'value': personalInfo.email},
      {'label': 'GitHub:', 'value': personalInfo.github},
      {'label': 'ORCID:', 'value': personalInfo.orcid},
      {
        'label': l10n.cvAddress,
        'value': personalInfo.addressKey,
      },
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          personalData
              .map((item) => _buildInfoRow(item['label']!, item['value']!))
              .toList(),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: _buildClickableValue(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildClickableValue(String value) {
    if (value.contains('@') ||
        value.contains('github.com') ||
        value.contains('orcid.org')) {
      var url = _normalizeUrl(value);

      return pw.RichText(
        text: pw.TextSpan(
          text: value,
          style: pw.TextStyle(
            fontSize: 10,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(url),
        ),
      );
    } else {
      return pw.Text(value, style: const pw.TextStyle(fontSize: 10));
    }
  }

  static pw.Widget _buildSectionHeader(
    String title,
    PdfColor sectionColor,
    PdfColor lightColor,
  ) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: lightColor,
        border: pw.Border(left: pw.BorderSide(color: sectionColor, width: 4)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: sectionColor,
        ),
      ),
    );
  }

  static pw.Widget _buildSection(
    String title,
    pw.Widget content,
    PdfColor sectionColor,
    PdfColor lightColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, sectionColor, lightColor),
        pw.SizedBox(height: 10),
        content,
      ],
    );
  }

  static pw.Widget _buildEducationContent(AppLocalizations l10n, List<EducationEntry> educationEntries) {

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          educationEntries
              .map(
                (entry) => pw.Column(
                  children: [
                    _buildEducationEntry(
                      _getLocalizedText(l10n, entry.periodKey),
                      _getLocalizedText(l10n, entry.titleKey),
                      _getLocalizedText(l10n, entry.institutionKey),
                      _getLocalizedText(l10n, entry.descriptionKey),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              )
              .toList(),
    );
  }

  static pw.Widget _buildEducationEntry(
    String period,
    String title,
    String institution,
    String description,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          period,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.wine.withValues(alpha: 0.7)),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(institution, style: const pw.TextStyle(fontSize: 10)),
        if (description.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          _buildRichText(description, fontSize: 9),
        ],
      ],
    );
  }

  static pw.Widget _buildWorkExperienceContent(AppLocalizations l10n, List<WorkExperienceEntry> workEntries) {

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          workEntries
              .map(
                (entry) => pw.Column(
                  children: [
                    _buildWorkEntry(
                      _getLocalizedText(l10n, entry.periodKey),
                      _getLocalizedText(l10n, entry.titleKey),
                      _getLocalizedText(l10n, entry.companyKey),
                      _getLocalizedText(l10n, entry.descriptionKey),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              )
              .toList(),
    );
  }

  static pw.Widget _buildWorkEntry(
    String period,
    String title,
    String company,
    String description,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          period,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.wine.withValues(alpha: 0.7)),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(company, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        _buildRichText(description, fontSize: 9),
      ],
    );
  }

  static pw.Widget _buildConferencesContent(AppLocalizations l10n, List<ConferenceEntry> conferenceEntries) {

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          conferenceEntries
              .map(
                (entry) => pw.Column(
                  children: [
                    _buildConferenceEntry(
                      _getLocalizedText(l10n, entry.periodKey),
                      _getLocalizedText(l10n, entry.titleKey),
                      _getLocalizedText(l10n, entry.locationKey),
                      _getLocalizedText(l10n, entry.descriptionKey),
                    ),
                    pw.SizedBox(height: 8),
                  ],
                ),
              )
              .toList(),
    );
  }

  static pw.Widget _buildConferenceEntry(
    String period,
    String title,
    String location,
    String description,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          period,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.wine.withValues(alpha: 0.7)),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          location,
          style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 3),
        _buildRichText(description, fontSize: 8),
      ],
    );
  }

  static pw.Widget _buildSkillsContent(AppLocalizations l10n, SkillsData skillsData) {

    final List<pw.Widget> skillWidgets = [];

    for (final category in skillsData.categories) {
      final categoryName = _getLocalizedText(l10n, category.nameKey);
      final skillNames = category.skills.map((skill) => _getLocalizedText(l10n, skill.nameKey)).toList();
      
      skillWidgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                categoryName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _convertFlutterToPdfColor(PortfolioTheme.wine.withValues(alpha: 0.7)),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Wrap(
                spacing: 8,
                runSpacing: 4,
                children: skillNames.map((skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: _convertFlutterToPdfColor(PortfolioTheme.iceWhite),
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(
                      color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue.withValues(alpha: 0.4)),
                      width: 0.8,
                    ),
                  ),
                  child: pw.Text(
                    skill,
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skillWidgets,
    );
  }

  static pw.Widget _buildPublicationTitle(Publication pub) {
    final titleText = '${pub.displayYear} - ${pub.title}';

    // If there's a DOI or URL, make the title clickable
    if (pub.doi != null && pub.doi!.isNotEmpty) {
      var doiUrl = 'https://doi.org/${pub.doi}';
      return pw.RichText(
        text: pw.TextSpan(
          text: titleText,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(doiUrl),
        ),
      );
    } else if (pub.url != null && pub.url!.isNotEmpty) {
      var url = _normalizeUrl(pub.url!);

      return pw.RichText(
        text: pw.TextSpan(
          text: titleText,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(url),
        ),
      );
    } else {
      return pw.Text(
        titleText,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      );
    }
  }

  /// Build publication links using localized view button text
  static pw.Widget _buildPublicationLinks(Publication pub, AppLocalizations l10n) {
    String? url;
    if (pub.doi != null && pub.doi!.isNotEmpty) {
      url = 'https://doi.org/${pub.doi}';
    } else if (pub.url != null && pub.url!.isNotEmpty) {
      url = _normalizeUrl(pub.url!);
    }

    if (url == null) {
      return pw.SizedBox.shrink();
    }

    return pw.RichText(
      text: pw.TextSpan(
        text: pub.getViewButtonText(l10n),
        style: pw.TextStyle(
          fontSize: 8,
          color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
          decoration: pw.TextDecoration.underline,
        ),
        annotation: pw.AnnotationUrl(url),
      ),
    );
  }

  /// Build publications organized by category with subsections
  static List<pw.Widget> _buildPublications(
    List<Publication> publications,
    AppLocalizations l10n,
  ) {
    // Filter to keep only main publication types for debugging
    final filteredPublications =
        publications
            .where(
              (pub) =>
                  pub.itemType == 'journalArticle' ||
                  pub.itemType == 'conferencePaper' ||
                  pub.itemType == 'bookSection',
            )
            .toList();
    final groupedPublications = _groupPublicationsByCategory(
      filteredPublications,
    );
    final categoryOrder = _getCategoryOrder();
    final List<pw.Widget> widgets = [];

    // Build widgets for each category
    for (final categoryKey in categoryOrder) {
      if (groupedPublications.containsKey(categoryKey) &&
          groupedPublications[categoryKey]!.isNotEmpty) {
        // Add category subsection title
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 12, bottom: 8),
            child: pw.Text(
              _getCategoryDisplayName(categoryKey, l10n).toUpperCase(),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _convertFlutterToPdfColor(PortfolioTheme.wine.withValues(alpha: 0.7)),
              ),
            ),
          ),
        );

        // Add publications for this category
        final categoryPubs = groupedPublications[categoryKey]!;
        for (final pub in categoryPubs) {
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8, left: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPublicationTitle(pub),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${pub.authorsString}. ${pub.displayVenue}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  if (pub.doi != null || pub.url != null) ...[
                    pw.SizedBox(height: 2),
                    _buildPublicationLinks(pub, l10n),
                  ],
                ],
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  static pw.Widget _buildFooter(AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Text(l10n.cvGdprConsent, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Bologna, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              l10n.name,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
