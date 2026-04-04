import 'dart:convert';

import 'package:apidash_core/apidash_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/models.dart';
import 'explorer_state_notifier.dart';

const int _kApiDetailDefaultTabIndex = 0;
const String _kApiDetailDefaultVersion = 'latest';
const String _kApiDetailNoPayloadNote = 'No sample payload';

typedef _TemplateKey = ({String apiId, String version});

class ApiDetailState {
  const ApiDetailState({
    this.apiSummary,
    this.selectedEndpointId,
    this.selectedVersion,
    this.selectedTab = _kApiDetailDefaultTabIndex,
    this.searchQuery = '',
    this.editableHeaders = const <MapEntry<String, String>>[],
  });

  final ApiSummary? apiSummary;

  final String? selectedEndpointId;

  final String? selectedVersion;

  final int selectedTab;

  final String searchQuery;

  final List<MapEntry<String, String>> editableHeaders;

  ApiDetailState copyWith({
    ApiSummary? apiSummary,
    bool clearApiSummary = false,
    String? selectedEndpointId,
    bool clearSelectedEndpointId = false,
    String? selectedVersion,
    bool clearSelectedVersion = false,
    int? selectedTab,
    String? searchQuery,
    List<MapEntry<String, String>>? editableHeaders,
  }) {
    return ApiDetailState(
      apiSummary: clearApiSummary ? null : (apiSummary ?? this.apiSummary),
      selectedEndpointId: clearSelectedEndpointId
          ? null
          : (selectedEndpointId ?? this.selectedEndpointId),
      selectedVersion: clearSelectedVersion
          ? null
          : (selectedVersion ?? this.selectedVersion),
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      editableHeaders: editableHeaders ?? this.editableHeaders,
    );
  }
}

class _ApiDetailStateNotifier extends StateNotifier<ApiDetailState> {
  _ApiDetailStateNotifier() : super(const ApiDetailState());

  void openApi(ApiSummary apiSummary) {
    state = state.copyWith(
      apiSummary: apiSummary,
      clearSelectedEndpointId: true,
      clearSelectedVersion: true,
      selectedTab: _kApiDetailDefaultTabIndex,
      searchQuery: '',
      editableHeaders: const <MapEntry<String, String>>[],
    );
  }

  void closeApi() {
    state = state.copyWith(
      clearApiSummary: true,
      clearSelectedEndpointId: true,
      clearSelectedVersion: true,
      selectedTab: _kApiDetailDefaultTabIndex,
      searchQuery: '',
      editableHeaders: const <MapEntry<String, String>>[],
    );
  }

  void selectEndpoint(Endpoint endpoint) {
    state = state.copyWith(
      selectedEndpointId: endpoint.id,
      editableHeaders: endpoint.headers.entries.toList(),
    );
  }

  void selectVersion(String version) {
    state = state.copyWith(
      selectedVersion: version,
      clearSelectedEndpointId: true,
      editableHeaders: const <MapEntry<String, String>>[],
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectTab(int tabIndex) {
    state = state.copyWith(selectedTab: tabIndex);
  }

  void addHeaderRow() {
    final nextHeaders = [
      ...state.editableHeaders,
      const MapEntry<String, String>('', ''),
    ];
    state = state.copyWith(editableHeaders: nextHeaders);
  }

  void removeHeaderRow(int index) {
    final nextHeaders = [...state.editableHeaders]..removeAt(index);
    state = state.copyWith(editableHeaders: nextHeaders);
  }

  void updateHeaderKey(int index, String value) {
    final nextHeaders = [...state.editableHeaders];
    nextHeaders[index] = MapEntry<String, String>(
      value,
      nextHeaders[index].value,
    );
    state = state.copyWith(editableHeaders: nextHeaders);
  }

  void updateHeaderValue(int index, String value) {
    final nextHeaders = [...state.editableHeaders];
    nextHeaders[index] = MapEntry<String, String>(
      nextHeaders[index].key,
      value,
    );
    state = state.copyWith(editableHeaders: nextHeaders);
  }
}

final apiDetailStateProvider =
    StateNotifierProvider<_ApiDetailStateNotifier, ApiDetailState>(
      (ref) => _ApiDetailStateNotifier(),
    );

final _apiDetailIndexProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, apiId) async {
      final service = ref.watch(apiExplorerServiceProvider);
      final sha = await ref.watch(explorerShaProvider.future);
      return service.getApiIndex(sha, apiId);
    });

final apiDetailAvailableVersionsProvider = Provider<AsyncValue<List<String>>>((
  ref,
) {
  final apiId = ref.watch(
    apiDetailStateProvider.select((state) => state.apiSummary?.id),
  );
  if (apiId == null) {
    return const AsyncValue.data(<String>[]);
  }
  return ref.watch(_apiDetailIndexProvider(apiId)).whenData(_extractVersions);
});

final apiDetailSelectedVersionProvider = Provider<String?>((ref) {
  final selectedVersion = ref.watch(
    apiDetailStateProvider.select((state) => state.selectedVersion),
  );
  final versionsAsyncValue = ref.watch(apiDetailAvailableVersionsProvider);
  final versions = versionsAsyncValue.maybeWhen(
    data: (values) => values,
    orElse: () => const <String>[],
  );

  if (selectedVersion != null && versions.contains(selectedVersion)) {
    return selectedVersion;
  }
  return versions.isNotEmpty ? versions.last : null;
});

final _apiDetailTemplatesByKeyProvider =
    FutureProvider.family<Map<String, dynamic>, _TemplateKey>((ref, key) async {
      final service = ref.watch(apiExplorerServiceProvider);
      final sha = await ref.watch(explorerShaProvider.future);
      return service.getTemplates(
        sha: sha,
        apiId: key.apiId,
        version: key.version,
      );
    });

final apiDetailTemplatesProvider = Provider<AsyncValue<Map<String, dynamic>>>((
  ref,
) {
  final apiId = ref.watch(
    apiDetailStateProvider.select((state) => state.apiSummary?.id),
  );
  final selectedVersion = ref.watch(apiDetailSelectedVersionProvider);

  if (apiId == null || selectedVersion == null) {
    return const AsyncValue.data(<String, dynamic>{'requests': <dynamic>[]});
  }

  return ref.watch(
    _apiDetailTemplatesByKeyProvider((apiId: apiId, version: selectedVersion)),
  );
});

final apiDetailRequestModelsProvider = Provider<AsyncValue<List<RequestModel>>>(
  (ref) {
    final templatesAsyncValue = ref.watch(apiDetailTemplatesProvider);
    return templatesAsyncValue.whenData(_extractRequestModels);
  },
);

final apiDetailFilteredEndpointsProvider = Provider<AsyncValue<List<Endpoint>>>(
  (ref) {
    final searchQuery = ref.watch(
      apiDetailStateProvider.select((state) => state.searchQuery),
    );
    final requestModelsAsyncValue = ref.watch(apiDetailRequestModelsProvider);

    return requestModelsAsyncValue.whenData((requestModels) {
      final endpoints = requestModels
          .map(_requestModelToEndpoint)
          .toList(growable: false);
      final normalizedQuery = searchQuery.toLowerCase().trim();
      if (normalizedQuery.isEmpty) {
        return endpoints;
      }
      return endpoints
          .where((endpoint) {
            return endpoint.path.toLowerCase().contains(normalizedQuery) ||
                endpoint.summary.toLowerCase().contains(normalizedQuery);
          })
          .toList(growable: false);
    });
  },
);

final apiDetailSelectedEndpointProvider = Provider<AsyncValue<Endpoint?>>((
  ref,
) {
  final selectedEndpointId = ref.watch(
    apiDetailStateProvider.select((state) => state.selectedEndpointId),
  );
  final endpointsAsyncValue = ref.watch(apiDetailFilteredEndpointsProvider);

  return endpointsAsyncValue.whenData((endpoints) {
    if (endpoints.isEmpty) {
      return null;
    }
    if (selectedEndpointId == null) {
      return endpoints.first;
    }
    return endpoints.firstWhere(
      (endpoint) => endpoint.id == selectedEndpointId,
      orElse: () => endpoints.first,
    );
  });
});

final apiDetailSelectedRequestModelProvider =
    Provider<AsyncValue<RequestModel?>>((ref) {
      final selectedEndpointId = ref.watch(
        apiDetailStateProvider.select((state) => state.selectedEndpointId),
      );
      final modelsAsyncValue = ref.watch(apiDetailRequestModelsProvider);

      return modelsAsyncValue.whenData((models) {
        if (models.isEmpty) {
          return null;
        }
        if (selectedEndpointId == null) {
          return models.first;
        }
        return models.firstWhere(
          (model) => model.id == selectedEndpointId,
          orElse: () => models.first,
        );
      });
    });

List<String> _extractVersions(Map<String, dynamic> json) {
  final singleVersion = json['version']?.toString().trim();

  final versionsRaw = json['versions'];
  if (versionsRaw is List) {
    final versions = versionsRaw
        .map((item) {
          if (item is Map) {
            return item['version']?.toString();
          }
          return item?.toString();
        })
        .whereType<String>()
        .map((version) => version.trim())
        .where((version) => version.isNotEmpty)
        .toList(growable: false);

    if (versions.isNotEmpty) {
      return versions.toSet().toList(growable: false);
    }
  }

  if (singleVersion != null && singleVersion.isNotEmpty) {
    return <String>[singleVersion];
  }

  return const <String>[_kApiDetailDefaultVersion];
}

List<RequestModel> _extractRequestModels(Map<String, dynamic> templates) {
  final requestsRaw = templates['requests'];
  if (requestsRaw is! List) {
    return const <RequestModel>[];
  }

  final requestModels = <RequestModel>[];
  for (final request in requestsRaw) {
    if (request is! Map) {
      continue;
    }
    try {
      final requestMap = Map<String, Object?>.from(request);
      requestModels.add(RequestModel.fromJson(requestMap));
    } catch (_) {}
  }
  return requestModels;
}

Endpoint _requestModelToEndpoint(RequestModel requestModel) {
  final request = requestModel.httpRequestModel;
  final path = _pathFromUrl(request?.url ?? '');
  final summary = requestModel.description.trim().isNotEmpty
      ? requestModel.description
      : (requestModel.name.trim().isNotEmpty ? requestModel.name : path);

  final headers = <String, String>{
    for (final header in request?.headers ?? const <NameValueModel>[])
      if (header.name.trim().isNotEmpty) header.name.trim(): header.value,
  };

  return Endpoint(
    id: requestModel.id,
    method: _toHttpMethod(request?.method),
    path: path,
    summary: summary,
    headers: headers,
    samplePayload: _samplePayloadFromBody(request?.body),
  );
}

HttpMethod _toHttpMethod(HTTPVerb? method) {
  return switch (method) {
    HTTPVerb.post => HttpMethod.post,
    HTTPVerb.put => HttpMethod.put,
    HTTPVerb.patch => HttpMethod.patch,
    HTTPVerb.delete => HttpMethod.delete,
    _ => HttpMethod.get,
  };
}

String _pathFromUrl(String url) {
  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) {
    return '/';
  }

  final uri = Uri.tryParse(trimmedUrl);
  if (uri == null) {
    return _decodeForDisplay(trimmedUrl);
  }
  if (uri.path.isEmpty) {
    return '/';
  }

  final value = uri.query.isNotEmpty ? '${uri.path}?${uri.query}' : uri.path;
  return _decodeForDisplay(value);
}

String _decodeForDisplay(String value) {
  try {
    return Uri.decodeFull(value);
  } catch (_) {
    return value;
  }
}

Map<String, dynamic> _samplePayloadFromBody(String? body) {
  final rawBody = body?.trim();
  if (rawBody == null || rawBody.isEmpty) {
    return const <String, dynamic>{'note': _kApiDetailNoPayloadNote};
  }
  try {
    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    if (decoded is List) {
      return <String, dynamic>{'items': decoded};
    }
    return <String, dynamic>{'value': decoded};
  } catch (_) {
    return <String, dynamic>{'raw': rawBody};
  }
}
