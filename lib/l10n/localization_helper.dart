import 'app_localizations.dart';

/// Centralized localization helper for all CV data keys
///
/// This helper provides a single point for retrieving localized text
/// across the entire application, eliminating code duplication
class LocalizationHelper {
  /// Retrieves localized text for a given key using the provided AppLocalizations instance
  ///
  /// Returns the localized text if the key exists, otherwise returns the key itself
  static String getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      // Personal info
      case 'jobTitle':
        return l10n.jobTitle;
      case 'cvBirthDate':
        return l10n.cvBirthDate;
      case 'cvNationalityValue':
        return l10n.cvNationalityValue;

      // Education entries
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

      // Institutions
      case 'universityBologna':
        return l10n.universityBologna;
      case 'kuLeuven':
        return l10n.kuLeuven;

      // Work experience entries
      case 'researchGrantHolderTitle':
        return l10n.researchGrantHolderTitle;
      case 'researchGrantHolderPeriod':
        return l10n.researchGrantHolderPeriod;
      case 'researchGrantHolderDescription':
        return l10n.researchGrantHolderDescription;
      case 'ficlit':
        return l10n.ficlit;
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

      // Conference entries
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
      case 'csvconfV9Conference2025Title':
        return l10n.csvconfV9Conference2025Title;
      case 'csvconfV9Conference2025Period':
        return l10n.csvconfV9Conference2025Period;
      case 'csvconfV9Conference2025Location':
        return l10n.csvconfV9Conference2025Location;
      case 'csvconfV9Conference2025Description':
        return l10n.csvconfV9Conference2025Description;

      // Skill categories
      case 'skillCategoryProgrammingLanguages':
        return l10n.skillCategoryProgrammingLanguages;
      case 'skillCategoryWebTechnologies':
        return l10n.skillCategoryWebTechnologies;
      case 'skillCategoryQueryLanguages':
        return l10n.skillCategoryQueryLanguages;
      case 'skillCategorySemanticWebTechnologies':
        return l10n.skillCategorySemanticWebTechnologies;
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

      // Individual skills
      case 'skillPython':
        return l10n.skillPython;
      case 'skillJavaScript':
        return l10n.skillJavaScript;
      case 'skillTypeScript':
        return l10n.skillTypeScript;
      case 'skillDart':
        return l10n.skillDart;
      case 'skillHTML5':
        return l10n.skillHTML5;
      case 'skillCSS':
        return l10n.skillCSS;
      case 'skillBootstrap':
        return l10n.skillBootstrap;
      case 'skillSPARQL':
        return l10n.skillSPARQL;
      case 'skillSQL':
        return l10n.skillSQL;
      case 'skillRDFSerializations':
        return l10n.skillRDFSerializations;
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
      case 'skillArch':
        return l10n.skillArch;

      // Europass CV keys
      case 'europassHeader':
        return l10n.europassHeader;
      case 'europassPersonalInfo':
        return l10n.europassPersonalInfo;
      case 'europassName':
        return l10n.europassName;
      case 'europassWorkExperience':
        return l10n.europassWorkExperience;
      case 'europassDates':
        return l10n.europassDates;
      case 'europassPosition':
        return l10n.europassPosition;
      case 'europassEmployer':
        return l10n.europassEmployer;
      case 'europassActivities':
        return l10n.europassActivities;
      case 'europassEducation':
        return l10n.europassEducation;
      case 'europassQualification':
        return l10n.europassQualification;
      case 'europassInstitution':
        return l10n.europassInstitution;
      case 'europassSubjects':
        return l10n.europassSubjects;
      case 'europassPersonalSkills':
        return l10n.europassPersonalSkills;
      case 'europassMotherTongue':
        return l10n.europassMotherTongue;
      case 'europassOtherLanguages':
        return l10n.europassOtherLanguages;
      case 'europassListening':
        return l10n.europassListening;
      case 'europassReading':
        return l10n.europassReading;
      case 'europassSpokenInteraction':
        return l10n.europassSpokenInteraction;
      case 'europassSpokenProduction':
        return l10n.europassSpokenProduction;
      case 'europassWriting':
        return l10n.europassWriting;
      case 'europassCefrReference':
        return l10n.europassCefrReference;
      case 'europassTechnicalSkills':
        return l10n.europassTechnicalSkills;
      case 'europassDrivingLicense':
        return l10n.europassDrivingLicense;
      case 'europassLicenseB':
        return l10n.europassLicenseB;
      case 'europassGdprConsent':
        return l10n.europassGdprConsent;

      // Language keys
      case 'languagesItalian':
        return l10n.languagesItalian;
      case 'languagesEnglish':
        return l10n.languagesEnglish;

      // Default case: return the key itself if no localization is found
      default:
        return key;
    }
  }
}
