/// Wraps all API responses: { "success": true, "data": T, "meta": {...} }
class ApiResponse<T> {
  final bool success;
  final T data;
  final String? message;

  const ApiResponse({required this.success, required this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      data: fromJsonT(json['data']),
      message: json['message'] as String?,
    );
  }
}

/// Wraps paginated responses:
/// { "success": true, "data": [...], "meta": { "page": 1, "limit": 20, "total": 100, "pages": 5 } }
class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse(
      {required this.success, required this.data, required this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      success: json['success'] as bool? ?? true,
      data: (json['data'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
          json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationMeta(
      {this.page = 1, this.limit = 20, this.total = 0, this.pages = 0});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 20,
        total: json['total'] as int? ?? 0,
        pages: json['pages'] as int? ?? 0,
      );

  bool get hasNextPage => page < pages;
}
