import '../config/app_config.dart';
import '../network/api_response.dart';

/// Helpers shared by the mock repositories.
mixin MockSupport {
  /// Stands in for network latency, so loading states are actually reachable
  /// while the UI is being built rather than only in theory.
  Future<void> settle() => Future<void>.delayed(AppConfig.mockLatency);

  /// Slices a list the same way the API paginates, including the `meta` block
  /// the paginator widget reads.
  Paginated<T> paginate<T>(
    List<T> all, {
    required int page,
    required int perPage,
  }) {
    final safePerPage = perPage.clamp(1, AppConfig.maxPerPage);
    final lastPage = all.isEmpty ? 1 : (all.length / safePerPage).ceil();
    final safePage = page.clamp(1, lastPage);
    final start = (safePage - 1) * safePerPage;
    final end = (start + safePerPage).clamp(0, all.length);

    return Paginated(
      items: start >= all.length ? const [] : all.sublist(start, end),
      meta: PageMeta(
        currentPage: safePage,
        lastPage: lastPage,
        perPage: safePerPage,
        total: all.length,
      ),
    );
  }
}
