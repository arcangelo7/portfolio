
class EducationEntry {
  final String id;
  final String? startDate;
  final String? endDate;
  final bool current;
  final String institutionKey;
  final String titleKey;
  final String periodKey;
  final String descriptionKey;
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
    required this.order,
  });

  factory EducationEntry.fromJson(Map<String, dynamic> json) {
    return EducationEntry(
      id: json['id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      current: json['current'] ?? false,
      institutionKey: json['institutionKey'],
      titleKey: json['titleKey'],
      periodKey: json['periodKey'],
      descriptionKey: json['descriptionKey'],
      order: json['order'] ?? 0,
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
    required this.order,
  });

  factory WorkExperienceEntry.fromJson(Map<String, dynamic> json) {
    return WorkExperienceEntry(
      id: json['id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      current: json['current'] ?? false,
      companyKey: json['companyKey'],
      titleKey: json['titleKey'],
      periodKey: json['periodKey'],
      descriptionKey: json['descriptionKey'],
      order: json['order'] ?? 0,
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
      id: json['id'],
      date: json['date'],
      endDate: json['endDate'],
      titleKey: json['titleKey'],
      periodKey: json['periodKey'],
      locationKey: json['locationKey'],
      descriptionKey: json['descriptionKey'],
      order: json['order'] ?? 0,
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

  Skill({
    required this.id,
    required this.nameKey,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      nameKey: json['nameKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKey': nameKey,
    };
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
      id: json['id'],
      nameKey: json['nameKey'],
      skills: (json['skills'] as List)
          .map((skill) => Skill.fromJson(skill))
          .toList(),
      order: json['order'] ?? 0,
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
      categories: (json['categories'] as List)
          .map((category) => SkillCategory.fromJson(category))
          .toList(),
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
  final String jobTitleKey;
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
    required this.jobTitleKey,
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
      name: json['name'],
      jobTitleKey: json['jobTitleKey'],
      birthDate: json['birthDate'],
      birthDateKey: json['birthDateKey'],
      nationalityKey: json['nationalityKey'],
      email: json['email'],
      github: json['github'],
      orcid: json['orcid'],
      addressKey: json['addressKey'],
      photoPath: json['photoPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobTitleKey': jobTitleKey,
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