import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/models.dart';
import '../services/services.dart';

const int _kExplorerMinPage = 1;
const int _kExplorerMaxPage = 9999;
const int _kExplorerDefaultPageSize = 6;
const String _kExplorerDefaultCategory = 'Utilities';
const String _kExplorerAllFilterLabel = 'All';

class ApiExplorerState {
  const ApiExplorerState({
    this.query = '',
    this.selectedFilter,
    this.currentPage = _kExplorerMinPage,
    this.pageSize = _kExplorerDefaultPageSize,
  });

  final String query;

  final String? selectedFilter;

  final int currentPage;

  final int pageSize;

  ApiExplorerState copyWith({
    String? query,
    String? selectedFilter,
    bool clearSelectedFilter = false,
    int? currentPage,
    int? pageSize,
  }) {
    return ApiExplorerState(
      query: query ?? this.query,
      selectedFilter: clearSelectedFilter
          ? null
          : (selectedFilter ?? this.selectedFilter),
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class _ApiExplorerStateNotifier extends StateNotifier<ApiExplorerState> {
  _ApiExplorerStateNotifier() : super(const ApiExplorerState());

  void onSearchChanged(String query) {
    state = state.copyWith(query: query, currentPage: _kExplorerMinPage);
  }

  void onFilterSelected(String? filter) {
    final isAllFilter =
        filter == null ||
        filter.toLowerCase() == _kExplorerAllFilterLabel.toLowerCase();
    state = state.copyWith(
      selectedFilter: isAllFilter ? null : filter,
      clearSelectedFilter: isAllFilter,
      currentPage: _kExplorerMinPage,
    );
  }

  void onPageChanged(int page) {
    final clampedPage = page.clamp(_kExplorerMinPage, _kExplorerMaxPage);
    state = state.copyWith(currentPage: clampedPage);
  }
}

final apiExplorerServiceProvider = Provider<ApiExplorerService>(
  (ref) => ApiExplorerService(),
);

final explorerShaProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(apiExplorerServiceProvider);
  return service.getLatestSha();
});

final explorerGlobalIndexProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(apiExplorerServiceProvider);
  final sha = await ref.watch(explorerShaProvider.future);
  return service.getGlobalIndex(sha);
});

final explorerApiSummariesProvider = Provider<AsyncValue<List<ApiSummary>>>((
  ref,
) {
  final indexAsyncValue = ref.watch(explorerGlobalIndexProvider);
  return indexAsyncValue.whenData(_extractApiSummaries);
});

final apiExplorerStateProvider =
    StateNotifierProvider<_ApiExplorerStateNotifier, ApiExplorerState>(
      (ref) => _ApiExplorerStateNotifier(),
    );

final apiExplorerPagedListProvider = Provider<List<ApiSummary>>((ref) {
  final explorerState = ref.watch(apiExplorerStateProvider);
  final filteredApis = ref.watch(_apiExplorerFilteredListProvider);
  final startIndex = (explorerState.currentPage - 1) * explorerState.pageSize;
  final endIndex = startIndex + explorerState.pageSize;
  if (startIndex >= filteredApis.length) {
    return const <ApiSummary>[];
  }
  final clampedEndIndex = endIndex > filteredApis.length
      ? filteredApis.length
      : endIndex;
  return filteredApis.sublist(startIndex, clampedEndIndex);
});

final apiExplorerTotalPagesProvider = Provider<int>((ref) {
  final explorerState = ref.watch(apiExplorerStateProvider);
  final filteredApis = ref.watch(_apiExplorerFilteredListProvider);
  return (filteredApis.length / explorerState.pageSize).ceil().clamp(
    _kExplorerMinPage,
    _kExplorerMaxPage,
  );
});

final _apiExplorerFilteredListProvider = Provider<List<ApiSummary>>((ref) {
  final explorerState = ref.watch(apiExplorerStateProvider);
  final apiSummariesAsyncValue = ref.watch(explorerApiSummariesProvider);
  return apiSummariesAsyncValue.maybeWhen(
    data: (apiSummaries) => _filterApis(apiSummaries, explorerState),
    orElse: () => const <ApiSummary>[],
  );
});

List<ApiSummary> _filterApis(List<ApiSummary> apis, ApiExplorerState state) {
  final normalizedQuery = state.query.toLowerCase().trim();
  return apis
      .where((api) {
        final matchesFilter =
            state.selectedFilter == null ||
            state.selectedFilter == _kExplorerAllFilterLabel ||
            api.category == state.selectedFilter;
        final matchesQuery =
            normalizedQuery.isEmpty ||
            api.name.toLowerCase().contains(normalizedQuery) ||
            api.description.toLowerCase().contains(normalizedQuery);
        return matchesFilter && matchesQuery;
      })
      .toList(growable: false);
}

ApiSummary _toApiSummary(Map<String, dynamic> json) {
  final id = json['id']?.toString() ?? 'unknown';
  final endpointCount = switch (json['endpointCount']) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value) ?? 0,
    _ => 0,
  };
  final name = (json['name']?.toString().trim().isNotEmpty ?? false)
      ? json['name'].toString()
      : _titleFromId(id);
  final description =
      json['description']?.toString() ?? 'No description available.';
  final category =
      json['category']?.toString() ??
      (json['tags'] is List && (json['tags'] as List).isNotEmpty
          ? (json['tags'] as List).first.toString()
          : _kExplorerDefaultCategory);

  return ApiSummary(
    id: id,
    name: name,
    description: description,
    endpointCount: endpointCount,
    category: category,
  );
}

List<ApiSummary> _extractApiSummaries(Map<String, dynamic> index) {
  final apisRaw = index['apis'];
  if (apisRaw is List) {
    return apisRaw
        .map((item) {
          if (item is Map) {
            return _toApiSummary(Map<String, dynamic>.from(item));
          }
          if (item is String) {
            return _toApiSummary(<String, dynamic>{'id': item});
          }
          return null;
        })
        .whereType<ApiSummary>()
        .toList(growable: false);
  }

  if (apisRaw is Map) {
    return apisRaw.entries
        .map((entry) {
          final apiId = entry.key.toString();
          final apiValue = entry.value;
          if (apiValue is Map) {
            final json = Map<String, dynamic>.from(apiValue);
            json.putIfAbsent('id', () => apiId);
            return _toApiSummary(json);
          }
          return _toApiSummary(<String, dynamic>{'id': apiId, 'name': apiId});
        })
        .toList(growable: false);
  }

  return const <ApiSummary>[];
}

String _titleFromId(String id) {
  return id
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
