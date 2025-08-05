import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cv_data.dart';

class CVDataService {
  static CVData? _cachedData;

  static Future<CVData> loadCVData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final personalInfoJson = await rootBundle.loadString(
        'assets/data/personal_info.json',
      );
      final educationJson = await rootBundle.loadString(
        'assets/data/education.json',
      );
      final workExperienceJson = await rootBundle.loadString(
        'assets/data/work_experience.json',
      );
      final conferencesJson = await rootBundle.loadString(
        'assets/data/conferences.json',
      );
      final skillsJson = await rootBundle.loadString('assets/data/skills.json');

      final personalInfo = PersonalInfo.fromJson(json.decode(personalInfoJson));

      final educationList =
          (json.decode(educationJson) as List)
              .map((item) => EducationEntry.fromJson(item))
              .toList();
      educationList.sort((a, b) => a.order.compareTo(b.order));

      final workExperienceList =
          (json.decode(workExperienceJson) as List)
              .map((item) => WorkExperienceEntry.fromJson(item))
              .toList();
      workExperienceList.sort((a, b) => a.order.compareTo(b.order));

      final conferencesList =
          (json.decode(conferencesJson) as List)
              .map((item) => ConferenceEntry.fromJson(item))
              .toList();
      conferencesList.sort((a, b) => a.order.compareTo(b.order));

      final skills = SkillsData.fromJson(json.decode(skillsJson));
      skills.categories.sort((a, b) => a.order.compareTo(b.order));

      _cachedData = CVData(
        personalInfo: personalInfo,
        education: educationList,
        workExperience: workExperienceList,
        conferences: conferencesList,
        skills: skills,
      );

      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load CV data: $e');
    }
  }

  static void clearCache() {
    _cachedData = null;
  }

  static Future<List<EducationEntry>> getEducation() async {
    final data = await loadCVData();
    return data.education;
  }

  static Future<List<WorkExperienceEntry>> getWorkExperience() async {
    final data = await loadCVData();
    return data.workExperience;
  }

  static Future<List<ConferenceEntry>> getConferences() async {
    final data = await loadCVData();
    return data.conferences;
  }

  static Future<SkillsData> getSkills() async {
    final data = await loadCVData();
    return data.skills;
  }

  static Future<PersonalInfo> getPersonalInfo() async {
    final data = await loadCVData();
    return data.personalInfo;
  }
}
