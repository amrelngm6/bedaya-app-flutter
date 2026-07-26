/// Generic paginated response wrapper that mirrors Laravel's default
/// paginator JSON structure.
///
/// ```json
/// {
///   "data": [...],
///   "current_page": 1,
///   "last_page": 5,
///   "per_page": 15,
///   "total": 72,
///   "from": 1,
///   "to": 15
/// }
/// ```
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage >= lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    dynamic jsonData,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final rawData = jsonData as List<dynamic>? ?? [];
    return PaginatedResponse(
      data: rawData
          .whereType<Map<String, dynamic>>()
          .map(fromJsonItem)
          .toList(),
      currentPage: json['data']['pagination']['current_page'] as int? ?? 1,
      lastPage: json['data']['pagination']['last_page'] as int? ?? 1,
      perPage: json['data']['pagination']['per_page'] as int? ?? 15,
      total: json['data']['pagination']['total'] as int? ?? 0,
      from: json['data']['pagination']['from'] as int?,
      to: json['data']['pagination']['to'] as int?,
    );
  }
}
