class Publication {
  final String key;
  final String title;
  final List<String> authors;
  final String? journal;
  final String? venue;
  final String? year;
  final String? doi;
  final String? url;
  final String? abstractText;
  final String itemType;
  final DateTime? dateAdded;
  final DateTime? dateModified;

  const Publication({
    required this.key,
    required this.title,
    required this.authors,
    this.journal,
    this.venue,
    this.year,
    this.doi,
    this.url,
    this.abstractText,
    required this.itemType,
    this.dateAdded,
    this.dateModified,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    final creators = data['creators'] as List<dynamic>? ?? [];
    final authors =
        creators
            .where((creator) => creator['creatorType'] == 'author')
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
      venue:
          data['conferenceName'] as String? ??
          data['proceedingsTitle'] as String?,
      year: data['date'] as String?,
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
    return '${authors.first} et al.';
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
      default:
        return l10n.viewUrl; // fallback to "View Article"
    }
  }

  String get citation {
    final venueText = displayVenue.isNotEmpty ? displayVenue : '';
    final yearText = displayYear;

    if (venueText.isNotEmpty) {
      return '$authorsString ($yearText). $title. $venueText.';
    } else {
      return '$authorsString ($yearText). $title.';
    }
  }

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
