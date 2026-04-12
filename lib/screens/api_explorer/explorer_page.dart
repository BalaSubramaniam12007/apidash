import 'package:apidash/models/models.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_detail_page.dart';
import 'explorer_body.dart';
import 'explorer_footer.dart';
import 'explorer_header.dart';

const List<String> _kExplorerFilters = <String>[
  'All',
  'AI',
  'Demo',
  'Finance',
  'Social',
  'Test',
  'Utilities',
  'Weather',
];

class ExplorerPage extends ConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explorerState = ref.watch(apiExplorerStateProvider);
    final pagedApis = ref.watch(apiExplorerPagedListProvider);
    final totalPages = ref.watch(apiExplorerTotalPagesProvider);
    final detailState = ref.watch(apiDetailStateProvider);
    final apiSummariesAsyncValue = ref.watch(explorerApiSummariesProvider);

    if (detailState.apiSummary != null) {
      return ApiDetailPage(apiSummary: detailState.apiSummary!);
    }

    return Column(
      children: <Widget>[
        _buildHeader(ref, explorerState),
        Expanded(
          child: _buildBody(context, ref, apiSummariesAsyncValue, pagedApis),
        ),
        ExplorerFooter(
          currentPage: explorerState.currentPage,
          totalPages: totalPages,
          onPageChanged: (page) =>
              ref.read(apiExplorerStateProvider.notifier).onPageChanged(page),
        ),
        AppStatusBar(
          networkLabel: 'NETWORK: CONNECTED',
          networkConnected: true,
          systemStateLabel: 'SYSTEM STABLE',
          onReload: () {
            ref.invalidate(explorerShaProvider);
            ref.invalidate(explorerGlobalIndexProvider);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(WidgetRef ref, ApiExplorerState explorerState) {
    return ExplorerHeader(
      filters: _kExplorerFilters,
      selectedFilter: explorerState.selectedFilter,
      onSearchChanged: (query) =>
          ref.read(apiExplorerStateProvider.notifier).onSearchChanged(query),
      onFilterSelected: (filter) =>
          ref.read(apiExplorerStateProvider.notifier).onFilterSelected(filter),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ApiSummary>> apiSummariesAsyncValue,
    List<ApiSummary> pagedApis,
  ) {
    return apiSummariesAsyncValue.when(
      data: (_) => ExplorerBody(
        apis: pagedApis,
        onTap: (apiSummary) =>
            ref.read(apiDetailStateProvider.notifier).openApi(apiSummary),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Unable to load APIs: $error',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
