// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

String _requiredString(Map<String, dynamic> json, String key) {
  return json[key] as String;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  return json[key] as String?;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  return json[key] as int;
}

Iterable<Map<String, dynamic>> _objectList(
  Map<String, dynamic> json,
  String key,
) {
  return (json[key] as List<dynamic>).cast<Map<String, dynamic>>();
}

class LanguageData {
  final MotherTongue motherTongue;
  final List<OtherLanguage> otherLanguages;

  LanguageData({required this.motherTongue, required this.otherLanguages});

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      motherTongue: MotherTongue.fromJson(
        json['motherTongue'] as Map<String, dynamic>,
      ),
      otherLanguages:
          _objectList(
            json,
            'otherLanguages',
          ).map(OtherLanguage.fromJson).toList(),
    );
  }
}

class MotherTongue {
  final String name;
  final int order;

  MotherTongue({required this.name, required this.order});

  factory MotherTongue.fromJson(Map<String, dynamic> json) {
    return MotherTongue(
      name: _requiredString(json, 'name'),
      order: _requiredInt(json, 'order'),
    );
  }
}

class OtherLanguage {
  final String name;
  final String listening;
  final String reading;
  final String spokenInteraction;
  final String spokenProduction;
  final String writing;
  final String? badgeUrl;
  final int order;

  OtherLanguage({
    required this.name,
    required this.listening,
    required this.reading,
    required this.spokenInteraction,
    required this.spokenProduction,
    required this.writing,
    this.badgeUrl,
    required this.order,
  });

  factory OtherLanguage.fromJson(Map<String, dynamic> json) {
    return OtherLanguage(
      name: _requiredString(json, 'name'),
      listening: _requiredString(json, 'listening'),
      reading: _requiredString(json, 'reading'),
      spokenInteraction: _requiredString(json, 'spokenInteraction'),
      spokenProduction: _requiredString(json, 'spokenProduction'),
      writing: _requiredString(json, 'writing'),
      badgeUrl: _optionalString(json, 'badgeUrl'),
      order: _requiredInt(json, 'order'),
    );
  }
}
