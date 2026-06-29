// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

String _requiredString(Map<String, dynamic> json, String key) {
  return json[key] as String;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  return json[key] as String?;
}

bool _optionalBool(Map<String, dynamic> json, String key) {
  return json[key] as bool? ?? false;
}

int _optionalInt(Map<String, dynamic> json, String key) {
  return json[key] as int? ?? 0;
}

Iterable<Map<String, dynamic>> _objectList(
  Map<String, dynamic> json,
  String key,
) {
  final values = json[key] as List<dynamic>? ?? <dynamic>[];
  return values.cast<Map<String, dynamic>>();
}

class EntryAttachment {
  final String type;
  final String? url;
  final String? asset;
  final String? label;

  EntryAttachment({required this.type, this.url, this.asset, this.label});

  factory EntryAttachment.fromJson(Map<String, dynamic> json) {
    return EntryAttachment(
      type: _requiredString(json, 'type'),
      url: _optionalString(json, 'url'),
      asset: _optionalString(json, 'asset'),
      label: _optionalString(json, 'label'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (url != null) 'url': url,
      if (asset != null) 'asset': asset,
      if (label != null) 'label': label,
    };
  }
}

class EducationEntry {
  final String id;
  final String? startDate;
  final String? endDate;
  final bool current;
  final String institutionKey;
  final String titleKey;
  final String periodKey;
  final String descriptionKey;
  final List<EntryAttachment> attachments;
  final int order;

  EducationEntry({
    required this.id,
    this.startDate,
    this.endDate,
    required this.current,
    required this.institutionKey,
    required this.titleKey,
    required this.periodKey,
    required this.descriptionKey,
    this.attachments = const [],
    required this.order,
  });

  factory EducationEntry.fromJson(Map<String, dynamic> json) {
    return EducationEntry(
      id: _requiredString(json, 'id'),
      startDate: _optionalString(json, 'startDate'),
      endDate: _optionalString(json, 'endDate'),
      current: _optionalBool(json, 'current'),
      institutionKey: _requiredString(json, 'institutionKey'),
      titleKey: _requiredString(json, 'titleKey'),
      periodKey: _requiredString(json, 'periodKey'),
      descriptionKey: _requiredString(json, 'descriptionKey'),
      attachments:
          _objectList(
            json,
            'attachments',
          ).map(EntryAttachment.fromJson).toList(),
      order: _optionalInt(json, 'order'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'current': current,
      'institutionKey': institutionKey,
      'titleKey': titleKey,
      'periodKey': periodKey,
      'descriptionKey': descriptionKey,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
      'order': order,
    };
  }
}

class WorkExperienceEntry {
  final String id;
  final String? startDate;
  final String? endDate;
  final bool current;
  final String companyKey;
  final String titleKey;
  final String periodKey;
  final String descriptionKey;
  final List<EntryAttachment> attachments;
  final int order;

  WorkExperienceEntry({
    required this.id,
    this.startDate,
    this.endDate,
    required this.current,
    required this.companyKey,
    required this.titleKey,
    required this.periodKey,
    required this.descriptionKey,
    this.attachments = const [],
    required this.order,
  });

  factory WorkExperienceEntry.fromJson(Map<String, dynamic> json) {
    return WorkExperienceEntry(
      id: _requiredString(json, 'id'),
      startDate: _optionalString(json, 'startDate'),
      endDate: _optionalString(json, 'endDate'),
      current: _optionalBool(json, 'current'),
      companyKey: _requiredString(json, 'companyKey'),
      titleKey: _requiredString(json, 'titleKey'),
      periodKey: _requiredString(json, 'periodKey'),
      descriptionKey: _requiredString(json, 'descriptionKey'),
      attachments:
          _objectList(
            json,
            'attachments',
          ).map(EntryAttachment.fromJson).toList(),
      order: _optionalInt(json, 'order'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'current': current,
      'companyKey': companyKey,
      'titleKey': titleKey,
      'periodKey': periodKey,
      'descriptionKey': descriptionKey,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
      'order': order,
    };
  }
}

class ConferenceEntry {
  final String id;
  final String date;
  final String? endDate;
  final String titleKey;
  final String periodKey;
  final String locationKey;
  final String descriptionKey;
  final int order;

  ConferenceEntry({
    required this.id,
    required this.date,
    this.endDate,
    required this.titleKey,
    required this.periodKey,
    required this.locationKey,
    required this.descriptionKey,
    required this.order,
  });

  factory ConferenceEntry.fromJson(Map<String, dynamic> json) {
    return ConferenceEntry(
      id: _requiredString(json, 'id'),
      date: _requiredString(json, 'date'),
      endDate: _optionalString(json, 'endDate'),
      titleKey: _requiredString(json, 'titleKey'),
      periodKey: _requiredString(json, 'periodKey'),
      locationKey: _requiredString(json, 'locationKey'),
      descriptionKey: _requiredString(json, 'descriptionKey'),
      order: _optionalInt(json, 'order'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'endDate': endDate,
      'titleKey': titleKey,
      'periodKey': periodKey,
      'locationKey': locationKey,
      'descriptionKey': descriptionKey,
      'order': order,
    };
  }
}

class Skill {
  final String id;
  final String nameKey;

  Skill({required this.id, required this.nameKey});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: _requiredString(json, 'id'),
      nameKey: _requiredString(json, 'nameKey'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nameKey': nameKey};
  }
}

class SkillCategory {
  final String id;
  final String nameKey;
  final List<Skill> skills;
  final int order;

  SkillCategory({
    required this.id,
    required this.nameKey,
    required this.skills,
    required this.order,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      id: _requiredString(json, 'id'),
      nameKey: _requiredString(json, 'nameKey'),
      skills: _objectList(json, 'skills').map(Skill.fromJson).toList(),
      order: _optionalInt(json, 'order'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKey': nameKey,
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'order': order,
    };
  }
}

class SkillsData {
  final List<SkillCategory> categories;

  SkillsData({required this.categories});

  factory SkillsData.fromJson(Map<String, dynamic> json) {
    return SkillsData(
      categories:
          _objectList(json, 'categories').map(SkillCategory.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}

class PersonalInfo {
  final String name;
  final String birthDate;
  final String birthDateKey;
  final String nationalityKey;
  final String email;
  final String github;
  final String orcid;
  final String addressKey;
  final String photoPath;

  PersonalInfo({
    required this.name,
    required this.birthDate,
    required this.birthDateKey,
    required this.nationalityKey,
    required this.email,
    required this.github,
    required this.orcid,
    required this.addressKey,
    required this.photoPath,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: _requiredString(json, 'name'),
      birthDate: _requiredString(json, 'birthDate'),
      birthDateKey: _requiredString(json, 'birthDateKey'),
      nationalityKey: _requiredString(json, 'nationalityKey'),
      email: _requiredString(json, 'email'),
      github: _requiredString(json, 'github'),
      orcid: _requiredString(json, 'orcid'),
      addressKey: _requiredString(json, 'addressKey'),
      photoPath: _requiredString(json, 'photoPath'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate,
      'birthDateKey': birthDateKey,
      'nationalityKey': nationalityKey,
      'email': email,
      'github': github,
      'orcid': orcid,
      'addressKey': addressKey,
      'photoPath': photoPath,
    };
  }
}

class CVData {
  final PersonalInfo personalInfo;
  final List<EducationEntry> education;
  final List<WorkExperienceEntry> workExperience;
  final List<ConferenceEntry> conferences;
  final SkillsData skills;

  CVData({
    required this.personalInfo,
    required this.education,
    required this.workExperience,
    required this.conferences,
    required this.skills,
  });
}
