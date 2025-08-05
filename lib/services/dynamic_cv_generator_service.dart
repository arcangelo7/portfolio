import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../services/zotero_service.dart';

class DynamicCVGeneratorService {
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
            color: PdfColor.fromHex('#0066cc'),
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

    final headerColor = PdfColor.fromHex('#1f4e79');
    final sectionColor = PdfColor.fromHex('#4a90e2');
    final lightBlue = PdfColor.fromHex('#e8f4fd');

    final header = await _buildHeader(headerColor, l10n);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 20,
        build: (pw.Context context) {
          return [
            header,
            pw.SizedBox(height: 20),
            _buildPersonalInfo(l10n),
            pw.SizedBox(height: 20),
            _buildSection(
              l10n.cvEducationTitle,
              _buildEducationContent(l10n),
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 15),
            _buildSection(
              l10n.cvWorkExperienceTitle,
              _buildWorkExperienceContent(l10n),
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 15),
            _buildSection(
              l10n.cvConferencesTitle,
              _buildConferencesContent(l10n),
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

  static Future<pw.Widget> _buildHeader(PdfColor headerColor, AppLocalizations l10n) async {
    final imageBytes = await rootBundle.load('assets/images/foto_cv.png');
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
                  l10n.name,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  l10n.jobTitle,
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

  static pw.Widget _buildPersonalInfo(AppLocalizations l10n) {
    final personalData = [
      {'label': l10n.cvDateOfBirth, 'value': l10n.cvBirthDate},
      {'label': l10n.cvNationality, 'value': l10n.cvNationalityValue},
      {'label': 'Email:', 'value': 'arcangelo.massari@unibo.it'},
      {'label': 'GitHub:', 'value': 'https://github.com/arcangelo7'},
      {'label': 'ORCID:', 'value': 'https://orcid.org/0000-0002-8420-0696'},
      {
        'label': l10n.cvAddress,
        'value': 'Via Zamboni 33, 40126, Bologna, Italia',
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
            color: PdfColor.fromHex('#0066cc'),
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

  static pw.Widget _buildEducationContent(AppLocalizations l10n) {
    final educationItems = [
      {
        'period': l10n.phdCulturalHeritagePeriod,
        'title': l10n.phdCulturalHeritageTitle,
        'institution': l10n.universityBologna,
        'description': l10n.phdCulturalHeritageDescription,
      },
      {
        'period': l10n.phdEngineeringPeriod,
        'title': l10n.phdEngineeringTitle,
        'institution': l10n.kuLeuven,
        'description': l10n.phdEngineeringDescription,
      },
      {
        'period': l10n.mastersPeriod,
        'title': l10n.mastersDegreeTitle,
        'institution': l10n.universityBologna,
        'description': l10n.mastersDescription,
      },
      {
        'period': l10n.bachelorsPeriod,
        'title': l10n.bachelorsDegreeTitle,
        'institution': l10n.universityBologna,
        'description': l10n.bachelorsDescription,
      },
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          educationItems
              .map(
                (item) => pw.Column(
                  children: [
                    _buildEducationEntry(
                      item['period']!,
                      item['title']!,
                      item['institution']!,
                      item['description']!,
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
            color: PdfColor.fromHex('#666666'),
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

  static pw.Widget _buildWorkExperienceContent(AppLocalizations l10n) {
    final workItems = [
      {
        'period': l10n.tutorPeriod,
        'title': l10n.tutorTitle,
        'company': l10n.universityBologna,
        'description': l10n.tutorDescription,
      },
      {
        'period': l10n.researchFellowPeriod,
        'title': l10n.researchFellowTitle,
        'company': l10n.researchCentreOpenScholarly,
        'description': l10n.researchFellowDescription,
      },
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          workItems
              .map(
                (item) => pw.Column(
                  children: [
                    _buildWorkEntry(
                      item['period']!,
                      item['title']!,
                      item['company']!,
                      item['description']!,
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
            color: PdfColor.fromHex('#666666'),
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

  static pw.Widget _buildConferencesContent(AppLocalizations l10n) {
    final conferenceItems = [
      {
        'period': l10n.aiucdConference2024Period,
        'title': l10n.aiucdConference2024Title,
        'location': l10n.aiucdConference2024Location,
        'description': l10n.aiucdConference2024Description,
      },
      {
        'period': l10n.cziHackathon2023Period,
        'title': l10n.cziHackathon2023Title,
        'location': l10n.cziHackathon2023Location,
        'description': l10n.cziHackathon2023Description,
      },
      {
        'period': l10n.adhoDhConf2023Period,
        'title': l10n.adhoDhConf2023Title,
        'location': l10n.adhoDhConf2023Location,
        'description': l10n.adhoDhConf2023Description,
      },
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          conferenceItems
              .map(
                (item) => pw.Column(
                  children: [
                    _buildConferenceEntry(
                      item['period']!,
                      item['title']!,
                      item['location']!,
                      item['description']!,
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
            color: PdfColor.fromHex('#666666'),
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
            color: PdfColor.fromHex('#0066cc'),
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
            color: PdfColor.fromHex('#0066cc'),
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
          color: PdfColor.fromHex('#0066cc'),
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
                color: PdfColor.fromHex('#666666'),
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
