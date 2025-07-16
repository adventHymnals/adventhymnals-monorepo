class SearchQuery {
  final String originalQuery;
  final String? hymnalAbbreviation;
  final int? hymnNumber;
  final String searchText;
  final bool hasHymnalFilter;

  const SearchQuery({
    required this.originalQuery,
    this.hymnalAbbreviation,
    this.hymnNumber,
    required this.searchText,
    required this.hasHymnalFilter,
  });

  @override
  String toString() {
    return 'SearchQuery(originalQuery: $originalQuery, hymnalAbbreviation: $hymnalAbbreviation, hymnNumber: $hymnNumber, searchText: $searchText, hasHymnalFilter: $hasHymnalFilter)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchQuery &&
        other.originalQuery == originalQuery &&
        other.hymnalAbbreviation == hymnalAbbreviation &&
        other.hymnNumber == hymnNumber &&
        other.searchText == searchText &&
        other.hasHymnalFilter == hasHymnalFilter;
  }

  @override
  int get hashCode {
    return originalQuery.hashCode ^
        hymnalAbbreviation.hashCode ^
        hymnNumber.hashCode ^
        searchText.hashCode ^
        hasHymnalFilter.hashCode;
  }
}