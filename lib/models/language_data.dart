// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

class LanguageData {
  final MotherTongue motherTongue;
  final List<OtherLanguage> otherLanguages;

  LanguageData({
    required this.motherTongue,
    required this.otherLanguages,
  });

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      motherTongue: MotherTongue.fromJson(json['motherTongue']),
      otherLanguages: (json['otherLanguages'] as List)
          .map((lang) => OtherLanguage.fromJson(lang))
          .toList(),
    );
  }
}

class MotherTongue {
  final String name;
  final int order;

  MotherTongue({
    required this.name,
    required this.order,
  });

  factory MotherTongue.fromJson(Map<String, dynamic> json) {
    return MotherTongue(
      name: json['name'],
      order: json['order'],
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
      name: json['name'],
      listening: json['listening'],
      reading: json['reading'],
      spokenInteraction: json['spokenInteraction'],
      spokenProduction: json['spokenProduction'],
      writing: json['writing'],
      badgeUrl: json['badgeUrl'],
      order: json['order'],
    );
  }
}
