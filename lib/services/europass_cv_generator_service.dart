import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/cv_data.dart';
import '../models/language_data.dart';
import '../services/cv_data_service.dart';

class EuropassCVGeneratorService {
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

  static Future<LanguageData> _loadLanguageData() async {
    final languagesJson = await rootBundle.loadString(
      'assets/data/languages.json',
    );
    return LanguageData.fromJson(json.decode(languagesJson));
  }

  /// Builds a markdown-style link as clickable PDF text.
  static pw.Widget _buildRichText(String text, {double fontSize = 12}) {
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return pw.Text(text, style: pw.TextStyle(fontSize: fontSize));
    }

    final List<pw.InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          pw.TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: pw.TextStyle(fontSize: fontSize),
          ),
        );
      }

      final linkText = match.group(1) ?? '';
      String linkUrl = match.group(2) ?? '';

      if (!linkUrl.startsWith('http://') && !linkUrl.startsWith('https://')) {
        if (linkUrl.startsWith('www.')) {
          linkUrl = 'https://$linkUrl';
        } else {
          linkUrl = 'https://$linkUrl';
        }
      }

      spans.add(
        pw.TextSpan(
          text: linkText,
          style: pw.TextStyle(
            fontSize: fontSize,
            color: PdfColors.blue700,
            decoration: pw.TextDecoration.underline,
          ),
          annotation: pw.AnnotationUrl(linkUrl),
        ),
      );

      lastMatchEnd = match.end;
    }

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

  static Future<Uint8List> generateEuropassCV(
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();
    final theme = await _createUnicodeTheme();
    final cvData = await CVDataService.loadCVData();
    final languageData = await _loadLanguageData();

    final PersonalInfo personalInfo = cvData.personalInfo;
    final List<EducationEntry> education = cvData.education;
    final List<WorkExperienceEntry> workExperience = cvData.workExperience;
    final SkillsData skills = cvData.skills;

    // Page 1: Header + Personal Info + Work Experience + Education (start)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          _buildHeader(l10n),
          pw.SizedBox(height: 20),

          // Personal Information Section
          _buildPersonalInformationSection(l10n, personalInfo),
          pw.SizedBox(height: 20),

          // Work Experience Section
          _buildWorkExperienceSection(l10n, workExperience),
          pw.SizedBox(height: 20),

          // Education Section
          _buildEducationSection(l10n, education),
        ],
      ),
    );

    // Page 2: Personal Skills + Languages + Driver's License + Footer
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Personal Skills Section
          _buildPersonalSkillsSection(l10n, skills, languageData),
          pw.SizedBox(height: 20),

          // Driver's License
          _buildDriversLicenseSection(l10n),
          pw.SizedBox(height: 40),

          // Footer with GDPR consent
          _buildFooter(l10n, personalInfo.name),
        ],
      ),
    );

    return pdf.save();
  }

  /// Builds the Europass header.
  static pw.Widget _buildHeader(AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassHeader'),
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds Personal Information section.
  static pw.Widget _buildPersonalInformationSection(
    AppLocalizations l10n,
    PersonalInfo personalInfo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassPersonalInfo'),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassName'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                personalInfo.name,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds Work Experience section.
  static pw.Widget _buildWorkExperienceSection(
    AppLocalizations l10n,
    List<WorkExperienceEntry> workExperience,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassWorkExperience'),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        ...workExperience.map((entry) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassDates'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.periodKey),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassPosition'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.titleKey),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassEmployer'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.companyKey),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassActivities'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _buildRichText(
                    LocalizationHelper.getLocalizedText(l10n, entry.descriptionKey),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
          ],
        )),
      ],
    );
  }

  /// Builds Education section.
  static pw.Widget _buildEducationSection(
    AppLocalizations l10n,
    List<EducationEntry> education,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassEducation'),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        ...education.map((entry) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassDates'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.periodKey),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassQualification'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.titleKey),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassInstitution'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, entry.institutionKey),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassSubjects'),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _buildRichText(
                    LocalizationHelper.getLocalizedText(l10n, entry.descriptionKey),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
          ],
        )),
      ],
    );
  }

  /// Builds Personal Skills section including languages, social, organizational,
  /// technical, and IT skills.
  static pw.Widget _buildPersonalSkillsSection(
    AppLocalizations l10n,
    SkillsData skills,
    LanguageData languageData,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassPersonalSkills'),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 12),

        // Mother Tongue
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassMotherTongue'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, languageData.motherTongue.name),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Other Languages with CEFR table
        _buildLanguageTable(l10n, languageData.otherLanguages),
        pw.SizedBox(height: 12),

        // Technical and IT Skills
        _buildTechnicalSkills(l10n, skills),
      ],
    );
  }

  /// Builds the CEFR language proficiency table.
  static pw.Widget _buildLanguageTable(
    AppLocalizations l10n,
    List<OtherLanguage> otherLanguages,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassOtherLanguages'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Table header
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              '',
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              LocalizationHelper.getLocalizedText(l10n, 'europassListening'),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              LocalizationHelper.getLocalizedText(l10n, 'europassReading'),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              LocalizationHelper.getLocalizedText(l10n, 'europassSpokenInteraction'),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              LocalizationHelper.getLocalizedText(l10n, 'europassSpokenProduction'),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              LocalizationHelper.getLocalizedText(l10n, 'europassWriting'),
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Data rows for each language
                      ...otherLanguages.map(
                        (lang) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                LocalizationHelper.getLocalizedText(l10n, lang.name),
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(lang.listening, style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(lang.reading, style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(lang.spokenInteraction, style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(lang.spokenProduction, style: const pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(lang.writing, style: const pw.TextStyle(fontSize: 9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    LocalizationHelper.getLocalizedText(l10n, 'europassCefrReference'),
                    style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds technical and IT skills.
  static pw.Widget _buildTechnicalSkills(
    AppLocalizations l10n,
    SkillsData skills,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassTechnicalSkills'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: skills.categories.map((category) {
                  final skillNames = category.skills
                      .map((skill) => LocalizationHelper.getLocalizedText(l10n, skill.nameKey))
                      .join(', ');
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '${LocalizationHelper.getLocalizedText(l10n, category.nameKey)}: ',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: skillNames,
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds Driver's License section.
  static pw.Widget _buildDriversLicenseSection(AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassDrivingLicense'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                LocalizationHelper.getLocalizedText(l10n, 'europassLicenseB'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds footer with GDPR consent.
  static pw.Widget _buildFooter(AppLocalizations l10n, String name) {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          LocalizationHelper.getLocalizedText(l10n, 'europassGdprConsent'),
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Bologna, $formattedDate',
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
