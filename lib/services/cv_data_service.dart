// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cv_data.dart';
import '../models/language_data.dart';

class CVDataService {
  static CVData? _cachedData;
  static Future<CVData>? _loadingFuture;

  static Future<CVData> loadCVData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _loadCVDataInternal();
    return _loadingFuture!;
  }

  static Future<CVData> _loadCVDataInternal() async {
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

      final personalInfo = PersonalInfo.fromJson(
        json.decode(personalInfoJson) as Map<String, dynamic>,
      );

      final educationList =
          (json.decode(educationJson) as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(EducationEntry.fromJson)
              .toList();
      educationList.sort((a, b) => a.order.compareTo(b.order));

      final workExperienceList =
          (json.decode(workExperienceJson) as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(WorkExperienceEntry.fromJson)
              .toList();
      workExperienceList.sort((a, b) => a.order.compareTo(b.order));

      final conferencesList =
          (json.decode(conferencesJson) as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(ConferenceEntry.fromJson)
              .toList();
      conferencesList.sort((a, b) => a.order.compareTo(b.order));

      final skills = SkillsData.fromJson(
        json.decode(skillsJson) as Map<String, dynamic>,
      );
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
    _loadingFuture = null;
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

  static Future<LanguageData> getLanguages() async {
    final languagesJson = await rootBundle.loadString(
      'assets/data/languages.json',
    );
    return LanguageData.fromJson(
      json.decode(languagesJson) as Map<String, dynamic>,
    );
  }
}
