class Publication {
  final String key;
  final String title;
  final List<String> authors;
  final String? journal;
  final String? venue;
  final String? year;
  final String? volume;
  final String? issue;
  final String? pages;
  final String? doi;
  final String? url;
  final String? abstractText;
  final String itemType;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final int? citationCount;
  final bool hasLoadedCitations;

  const Publication({
    required this.key,
    required this.title,
    required this.authors,
    this.journal,
    this.venue,
    this.year,
    this.volume,
    this.issue,
    this.pages,
    this.doi,
    this.url,
    this.abstractText,
    required this.itemType,
    this.dateAdded,
    this.dateModified,
    this.citationCount,
    this.hasLoadedCitations = false,
  });

  static String? _extractVenue(Map<String, dynamic> data, String itemType) {
    switch (itemType) {
      case 'computerProgram':
        return null;
      case 'presentation':
        final meetingName = data['meetingName'] as String?;
        final place = data['place'] as String?;

        if (meetingName != null && place != null) {
          return '$meetingName, $place';
        } else if (meetingName != null) {
          return meetingName;
        } else if (place != null) {
          return place;
        } else {
          return null;
        }
      case 'bookSection':
        return data['bookTitle'] as String?;
      case 'thesis':
        final university = data['university'] as String?;
        final place = data['place'] as String?;

        if (university != null && place != null) {
          return '$university, $place';
        } else if (university != null) {
          return university;
        } else if (place != null) {
          return place;
        } else {
          return null;
        }
      case 'report':
        final institution = data['institution'] as String?;
        final place = data['place'] as String?;

        if (institution != null && place != null) {
          return '$institution, $place';
        } else if (institution != null) {
          return institution;
        } else if (place != null) {
          return place;
        } else {
          return null;
        }
      default:
        return data['conferenceName'] as String? ??
            data['proceedingsTitle'] as String?;
    }
  }

  factory Publication.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemType = data['itemType'] as String? ?? 'unknown';

    final creators = data['creators'] as List<dynamic>? ?? [];

    String primaryCreatorType;
    switch (itemType) {
      case 'computerProgram':
        primaryCreatorType = 'programmer';
        break;
      case 'presentation':
        primaryCreatorType = 'presenter';
        break;
      default:
        primaryCreatorType = 'author';
        break;
    }

    final authors =
        creators
            .where((creator) => creator['creatorType'] == primaryCreatorType)
            .map((creator) {
              final firstName = creator['firstName'] as String? ?? '';
              final lastName = creator['lastName'] as String? ?? '';
              return '$firstName $lastName'.trim();
            })
            .where((name) => name.isNotEmpty)
            .toList();

    return Publication(
      key: json['key'] as String,
      title: data['title'] as String? ?? 'Untitled',
      authors: authors,
      journal: data['publicationTitle'] as String?,
      venue: _extractVenue(data, itemType),
      year: data['date'] as String?,
      volume: data['volume'] as String?,
      issue: data['issue'] as String?,
      pages: data['pages'] as String?,
      doi: data['DOI'] as String?,
      url: data['url'] as String?,
      abstractText: data['abstractNote'] as String?,
      itemType: data['itemType'] as String? ?? 'unknown',
      dateAdded:
          data['dateAdded'] != null
              ? DateTime.tryParse(data['dateAdded'] as String)
              : null,
      dateModified:
          data['dateModified'] != null
              ? DateTime.tryParse(data['dateModified'] as String)
              : null,
    );
  }

  String get authorsString {
    if (authors.isEmpty) return 'Unknown Author';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return '${authors.first} & ${authors.last}';
    return authors.join(', ');
  }

  String get displayVenue {
    return journal ?? venue ?? 'Unknown Venue';
  }

  String get displayYear {
    if (year == null || year!.isEmpty) return 'Unknown Year';
    final yearMatch = RegExp(r'\d{4}').firstMatch(year!);
    return yearMatch?.group(0) ?? year!;
  }

  String getCategoryDisplayName(dynamic l10n) {
    switch (itemType) {
      case 'journalArticle':
        return l10n.categoryJournalArticle;
      case 'conferencePaper':
        return l10n.categoryConferencePaper;
      case 'book':
        return l10n.categoryBook;
      case 'bookSection':
        return l10n.categoryBookSection;
      case 'computerProgram':
        return l10n.categorySoftware;
      case 'presentation':
        return l10n.categoryPresentation;
      case 'thesis':
        return l10n.categoryThesis;
      case 'report':
        return l10n.categoryReport;
      default:
        return l10n.categoryOther;
    }
  }

  String getViewButtonText(dynamic l10n) {
    switch (itemType) {
      case 'journalArticle':
        return l10n.viewUrl; // "View Article"
      case 'conferencePaper':
        return l10n.viewPaper; // "View Paper"
      case 'book':
        return l10n.viewBook; // "View Book"
      case 'bookSection':
        return l10n.viewChapter; // "View Chapter"
      case 'computerProgram':
        return l10n.viewSoftware; // "View Software"
      case 'presentation':
        return l10n.viewPresentation; // "View Presentation"
      case 'thesis':
        return l10n.viewThesis; // "View Thesis"
      case 'report':
        return l10n.viewReport; // "View Report"
      default:
        return l10n.viewUrl; // fallback to "View Article"
    }
  }

  String get citation {
    final venueText = (journal?.isNotEmpty == true) 
        ? journal! 
        : (venue?.isNotEmpty == true) 
            ? venue! 
            : '';
    final yearText = displayYear;

    if (venueText.isNotEmpty) {
      return '$authorsString ($yearText). $title. $venueText.';
    } else {
      return '$authorsString ($yearText). $title.';
    }
  }

  Publication copyWith({
    String? key,
    String? title,
    List<String>? authors,
    String? journal,
    String? venue,
    String? year,
    String? volume,
    String? issue,
    String? pages,
    String? doi,
    String? url,
    String? abstractText,
    String? itemType,
    DateTime? dateAdded,
    DateTime? dateModified,
    int? citationCount,
    bool? hasLoadedCitations,
  }) {
    return Publication(
      key: key ?? this.key,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      journal: journal ?? this.journal,
      venue: venue ?? this.venue,
      year: year ?? this.year,
      volume: volume ?? this.volume,
      issue: issue ?? this.issue,
      pages: pages ?? this.pages,
      doi: doi ?? this.doi,
      url: url ?? this.url,
      abstractText: abstractText ?? this.abstractText,
      itemType: itemType ?? this.itemType,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      citationCount: citationCount ?? this.citationCount,
      hasLoadedCitations: hasLoadedCitations ?? this.hasLoadedCitations,
    );
  }

  bool get hasDoi => doi != null && doi!.isNotEmpty;

  @override
  String toString() => citation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Publication && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
