import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/publication.dart';
import '../models/cv_data.dart';
import '../services/zotero_service.dart';
import '../services/cv_data_service.dart';
import '../main.dart';
import '../utils/publication_utils.dart';

class DynamicCVGeneratorService {
  static PdfColor _convertFlutterToPdfColor(Color flutterColor) {
    return PdfColor(
      (flutterColor.r * 255.0).round() / 255.0,
      (flutterColor.g * 255.0).round() / 255.0,
      (flutterColor.b * 255.0).round() / 255.0,
      flutterColor.a,
    );
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

  static pw.Widget _buildRichText(String text, {double fontSize = 12}) {
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
      var linkUrl = PublicationUtils.normalizeUrl(match.group(2) ?? '');

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
    final sectionColor = _convertFlutterToPdfColor(
      PortfolioTheme.cobaltBlue.withValues(alpha: 0.8),
    );
    final lightBlue = _convertFlutterToPdfColor(PortfolioTheme.iceWhite);

    final header = await _buildHeader(headerColor, l10n, cvData.personalInfo);

    // First page: Header, Personal Info, Education
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
            _buildSectionHeader(l10n.cvEducationTitle, sectionColor, lightBlue),
            pw.SizedBox(height: 10),
            ..._buildEducationAsList(l10n, cvData.education),
          ];
        },
      ),
    );

    // Second page: Work Experience, Conferences and Skills
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 20,
        build: (pw.Context context) {
          return [
            _buildSectionHeader(
              l10n.cvWorkExperienceTitle,
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 10),
            ..._buildWorkExperienceAsList(l10n, cvData.workExperience),
            pw.SizedBox(height: 20),
            // Conferences using the same pattern as publications
            _buildSectionHeader(
              l10n.cvConferencesTitle,
              sectionColor,
              lightBlue,
            ),
            pw.SizedBox(height: 10),
            ..._buildConferencesAsList(l10n, cvData.conferences),
            pw.SizedBox(height: 20),
            // Skills using the same pattern as publications and conferences
            _buildSectionHeader(l10n.cvSkillsTitle, sectionColor, lightBlue),
            pw.SizedBox(height: 10),
            ..._buildSkillsAsList(l10n, cvData.skills),
            // Add footer here if no publications
            if (publications.isEmpty) ...[
              pw.SizedBox(height: 20),
              _buildFooter(l10n),
            ],
          ];
        },
      ),
    );

    // Third page: Publications (if any) and Footer
    if (publications.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          maxPages: 20,
          build: (pw.Context context) {
            return [
              _buildSectionHeader(
                l10n.cvPublicationsTitle,
                sectionColor,
                lightBlue,
              ),
              pw.SizedBox(height: 10),
              ..._buildPublications(publications, l10n),
              pw.SizedBox(height: 20),
              _buildFooter(l10n),
            ];
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<pw.Widget> _buildHeader(
    PdfColor headerColor,
    AppLocalizations l10n,
    PersonalInfo personalInfo,
  ) async {
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
                  LocalizationHelper.getLocalizedText(
                    l10n,
                    personalInfo.jobTitleKey,
                  ),
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

  static pw.Widget _buildPersonalInfo(
    AppLocalizations l10n,
    PersonalInfo personalInfo,
  ) {
    final personalData = [
      {
        'label': l10n.cvDateOfBirth,
        'value': LocalizationHelper.getLocalizedText(
          l10n,
          personalInfo.birthDateKey,
        ),
      },
      {
        'label': l10n.cvNationality,
        'value': LocalizationHelper.getLocalizedText(
          l10n,
          personalInfo.nationalityKey,
        ),
      },
      {'label': 'Email:', 'value': personalInfo.email},
      {'label': 'GitHub:', 'value': personalInfo.github},
      {'label': 'ORCID:', 'value': personalInfo.orcid},
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
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
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
      var url = PublicationUtils.normalizeUrl(value);

      return pw.RichText(
        text: pw.TextSpan(
          text: value,
          style: pw.TextStyle(
            fontSize: 12,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(url),
        ),
      );
    } else {
      return pw.Text(value, style: const pw.TextStyle(fontSize: 12));
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

  static List<pw.Widget> _buildEducationAsList(
    AppLocalizations l10n,
    List<EducationEntry> educationEntries,
  ) {
    return educationEntries
        .map(
          (entry) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: _buildEducationEntry(
              LocalizationHelper.getLocalizedText(l10n, entry.periodKey),
              LocalizationHelper.getLocalizedText(l10n, entry.titleKey),
              LocalizationHelper.getLocalizedText(l10n, entry.institutionKey),
              LocalizationHelper.getLocalizedText(l10n, entry.descriptionKey),
            ),
          ),
        )
        .toList();
  }

  static pw.Widget _buildEducationEntry(
    String period,
    String title,
    String institution,
    String description,
  ) {
    return pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              period,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _convertFlutterToPdfColor(
                  PortfolioTheme.wine.withValues(alpha: 0.7),
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(institution, style: const pw.TextStyle(fontSize: 12)),
            if (description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              _buildRichText(description, fontSize: 12),
            ],
          ],
        ),
      ],
    );
  }

  /// Build work experience as a list of widgets like conferences and skills for better page breaking
  static List<pw.Widget> _buildWorkExperienceAsList(
    AppLocalizations l10n,
    List<WorkExperienceEntry> workEntries,
  ) {
    return workEntries
        .map(
          (entry) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: _buildWorkEntry(
              LocalizationHelper.getLocalizedText(l10n, entry.periodKey),
              LocalizationHelper.getLocalizedText(l10n, entry.titleKey),
              LocalizationHelper.getLocalizedText(l10n, entry.companyKey),
              LocalizationHelper.getLocalizedText(l10n, entry.descriptionKey),
            ),
          ),
        )
        .toList();
  }

  static pw.Widget _buildWorkEntry(
    String period,
    String title,
    String company,
    String description,
  ) {
    return pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              period,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _convertFlutterToPdfColor(
                  PortfolioTheme.wine.withValues(alpha: 0.7),
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(company, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 4),
            _buildRichText(description, fontSize: 12),
          ],
        ),
      ],
    );
  }

  /// Build conferences as a list of widgets like publications for better page breaking
  static List<pw.Widget> _buildConferencesAsList(
    AppLocalizations l10n,
    List<ConferenceEntry> conferenceEntries,
  ) {
    return conferenceEntries
        .map(
          (entry) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: _buildConferenceEntry(
              LocalizationHelper.getLocalizedText(l10n, entry.periodKey),
              LocalizationHelper.getLocalizedText(l10n, entry.titleKey),
              LocalizationHelper.getLocalizedText(l10n, entry.locationKey),
              LocalizationHelper.getLocalizedText(l10n, entry.descriptionKey),
            ),
          ),
        )
        .toList();
  }

  static pw.Widget _buildConferenceEntry(
    String period,
    String title,
    String location,
    String description,
  ) {
    return pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              period,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _convertFlutterToPdfColor(
                  PortfolioTheme.wine.withValues(alpha: 0.7),
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 1),
            pw.Text(
              location,
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 3),
            _buildRichText(description, fontSize: 12),
          ],
        ),
      ],
    );
  }

  /// Build skills as a list of widgets like publications and conferences for better page breaking
  static List<pw.Widget> _buildSkillsAsList(
    AppLocalizations l10n,
    SkillsData skillsData,
  ) {
    final List<pw.Widget> skillWidgets = [];

    for (final category in skillsData.categories) {
      final categoryName = LocalizationHelper.getLocalizedText(
        l10n,
        category.nameKey,
      );
      final skillNames =
          category.skills
              .map(
                (skill) =>
                    LocalizationHelper.getLocalizedText(l10n, skill.nameKey),
              )
              .toList();

      skillWidgets.add(
        pw.Wrap(
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    categoryName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: _convertFlutterToPdfColor(
                        PortfolioTheme.wine.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        skillNames
                            .map(
                              (skill) => pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: _convertFlutterToPdfColor(
                                    PortfolioTheme.iceWhite,
                                  ),
                                  borderRadius: pw.BorderRadius.circular(10),
                                ),
                                child: pw.Text(
                                  skill,
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    color: _convertFlutterToPdfColor(
                                      PortfolioTheme.cobaltBlue,
                                    ),
                                    fontWeight: pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return skillWidgets;
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
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _convertFlutterToPdfColor(PortfolioTheme.cobaltBlue),
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(doiUrl),
        ),
      );
    } else if (pub.url != null && pub.url!.isNotEmpty) {
      var url = PublicationUtils.normalizeUrl(pub.url!);

      return pw.RichText(
        text: pw.TextSpan(
          text: titleText,
          style: pw.TextStyle(
            fontSize: 12,
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
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      );
    }
  }

  /// Build publication links using localized view button text
  static pw.Widget _buildPublicationLinks(
    Publication pub,
    AppLocalizations l10n,
  ) {
    String? url;
    if (pub.doi != null && pub.doi!.isNotEmpty) {
      url = 'https://doi.org/${pub.doi}';
    } else if (pub.url != null && pub.url!.isNotEmpty) {
      url = PublicationUtils.normalizeUrl(pub.url!);
    }

    if (url == null) {
      return pw.SizedBox.shrink();
    }

    return pw.RichText(
      text: pw.TextSpan(
        text: pub.getViewButtonText(l10n),
        style: pw.TextStyle(
          fontSize: 11,
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
    final groupedPublications = PublicationUtils.groupPublicationsByCategory(
      publications,
    );
    final categoryOrder = PublicationUtils.getCategoryOrder();
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
              PublicationUtils.getCategoryDisplayName(
                categoryKey,
                l10n,
              ).toUpperCase(),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _convertFlutterToPdfColor(
                  PortfolioTheme.wine.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        );

        // Add publications for this category
        final categoryPubs = groupedPublications[categoryKey]!;
        for (final pub in categoryPubs) {
          widgets.add(
            pw.Wrap(
              children: [
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8, left: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPublicationTitle(pub),
                      pw.SizedBox(height: 2),
                      if (pub.itemType != 'computerProgram' &&
                          pub.displayVenue != 'Unknown Venue') ...[
                        pw.Text(
                          PublicationUtils.buildVenueWithDetails(
                            pub.displayVenue,
                            pub.volume,
                            pub.issue,
                            pub.pages,
                          ),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                      ],
                      if (pub.doi != null || pub.url != null) ...[
                        if (pub.itemType == 'computerProgram' ||
                            pub.displayVenue == 'Unknown Venue')
                          pw.SizedBox(height: 2),
                        _buildPublicationLinks(pub, l10n),
                      ],
                    ],
                  ),
                ),
              ],
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
        pw.Text(l10n.cvGdprConsent, style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Bologna, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 12),
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
