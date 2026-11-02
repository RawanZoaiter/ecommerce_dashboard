/// The envelope every endpoint returns, success or failure (frontend guide §3).
///
/// `message` is written for developers and must never be shown to a user; the
/// UI branches on [code] and renders its own localized text.
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.requestId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) parseData, {
    String? requestId,
  }) {
    return ApiResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : parseData(json['data']),
      requestId: requestId,
    );
  }

  final int code;
  final String message;
  final T? data;

  /// From the `X-Request-ID` response header. The guide asks for it when
  /// reporting a problem, so it travels with the response and into failures.
  final String? requestId;

  bool get isSuccess => code >= 200 && code < 300;
}

/// Page information from a paginated list endpoint (frontend guide §5.8).
class PageMeta {
  const PageMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    return PageMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  const PageMeta.empty()
    : currentPage = 1,
      lastPage = 1,
      perPage = 0,
      total = 0;

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasNext => currentPage < lastPage;
  bool get hasPrevious => currentPage > 1;

  /// 1-based index of the first row on this page, for "21–40 of 97".
  int get from => total == 0 ? 0 : (currentPage - 1) * perPage + 1;
  int get to => total == 0 ? 0 : (from + perPage - 1).clamp(0, total);
}

/// A page of results plus the metadata needed to drive the paginator.
class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  const Paginated.empty() : items = const [], meta = const PageMeta.empty();

  final List<T> items;
  final PageMeta meta;

  bool get isEmpty => items.isEmpty;

  Paginated<R> map<R>(R Function(T item) transform) {
    return Paginated(items: items.map(transform).toList(), meta: meta);
  }
}
