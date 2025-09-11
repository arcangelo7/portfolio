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
      case 'skillCategoryMarkupAndTemplating':
        return l10n.skillCategoryMarkupAndTemplating;
      case 'skillCategoryStylingAndDesign':
        return l10n.skillCategoryStylingAndDesign;
      case 'skillCategoryQueryAndTransform':
        return l10n.skillCategoryQueryAndTransform;
      case 'skillCategorySemanticWebAndRDF':
        return l10n.skillCategorySemanticWebAndRDF;
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
      case 'skillHTML':
        return l10n.skillHTML;
      case 'skillXML':
        return l10n.skillXML;
      case 'skillTEI':
        return l10n.skillTEI;
      case 'skillCSS':
        return l10n.skillCSS;
      case 'skillSASS':
        return l10n.skillSASS;
      case 'skillBootstrap':
        return l10n.skillBootstrap;
      case 'skillSPARQL':
        return l10n.skillSPARQL;
      case 'skillSQL':
        return l10n.skillSQL;
      case 'skillXPath':
        return l10n.skillXPath;
      case 'skillXQuery':
        return l10n.skillXQuery;
      case 'skillXSLT':
        return l10n.skillXSLT;
      case 'skillRDF':
        return l10n.skillRDF;
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

      // Default case: return the key itself if no localization is found
      default:
        return key;
    }
  }
}
