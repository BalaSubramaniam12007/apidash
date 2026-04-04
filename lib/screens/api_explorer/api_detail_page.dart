import 'package:apidash/models/models.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_detail_header.dart';
import 'api_detail_import_actions.dart';
import 'api_detail_left_pane.dart';
import 'api_detail_right_pane.dart';

class ApiDetailPage extends ConsumerWidget {
  const ApiDetailPage({super.key, required this.apiSummary});

  final ApiSummary apiSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(apiDetailStateProvider);
    final endpointsAsyncValue = ref.watch(apiDetailFilteredEndpointsProvider);
    final selectedEndpointAsyncValue = ref.watch(
      apiDetailSelectedEndpointProvider,
    );
    final selectedRequestModelAsyncValue = ref.watch(
      apiDetailSelectedRequestModelProvider,
    );
    final requestModelsAsyncValue = ref.watch(apiDetailRequestModelsProvider);
    final versionsAsyncValue = ref.watch(apiDetailAvailableVersionsProvider);
    final selectedVersion = ref.watch(apiDetailSelectedVersionProvider);

    final endpoints = endpointsAsyncValue.maybeWhen(
      data: (values) => values,
      orElse: () => const <Endpoint>[],
    );
    final selectedEndpoint = selectedEndpointAsyncValue.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    _ensureEndpointSelected(ref, detailState, selectedEndpoint);

    return Column(
      children: <Widget>[
        _buildHeader(
          context,
          ref,
          versionsAsyncValue,
          selectedVersion,
          requestModelsAsyncValue,
        ),
        Expanded(
          child: _buildBody(
            context,
            ref,
            detailState,
            endpoints,
            selectedEndpoint,
            selectedRequestModelAsyncValue,
          ),
        ),
        const AppStatusBar(
          networkLabel: 'NETWORK: CONNECTED',
          networkConnected: true,
          latencyLabel: 'LATENCY: 24MS',
          systemStateLabel: 'SYSTEM STABLE',
        ),
      ],
    );
  }

  void _ensureEndpointSelected(
    WidgetRef ref,
    ApiDetailState detailState,
    Endpoint? selectedEndpoint,
  ) {
    if (detailState.selectedEndpointId == null && selectedEndpoint != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(apiDetailStateProvider.notifier)
            .selectEndpoint(selectedEndpoint);
      });
    }
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<String>> versionsAsyncValue,
    String? selectedVersion,
    AsyncValue<List<RequestModel>> requestModelsAsyncValue,
  ) {
    return ApiDetailHeader(
      apiSummary: apiSummary,
      versions: versionsAsyncValue.maybeWhen(
        data: (values) => values,
        orElse: () => const <String>[],
      ),
      selectedVersion: selectedVersion,
      onVersionChanged: (version) {
        if (version == null) {
          return;
        }
        ref.read(apiDetailStateProvider.notifier).selectVersion(version);
      },
      onImportAll: () {
        final requestModels = requestModelsAsyncValue.maybeWhen(
          data: (models) => models,
          orElse: () => const <RequestModel>[],
        );
        importRequestModelsToWorkspace(context, ref, requestModels);
      },
      onBack: () => ref.read(apiDetailStateProvider.notifier).closeApi(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ApiDetailState detailState,
    List<Endpoint> endpoints,
    Endpoint? selectedEndpoint,
    AsyncValue<RequestModel?> selectedRequestModelAsyncValue,
  ) {
    return Row(
      children: <Widget>[
        ApiDetailLeftPane(
          endpoints: endpoints,
          selectedEndpoint: selectedEndpoint,
          onSearchChanged: (query) => ref
              .read(apiDetailStateProvider.notifier)
              .updateSearchQuery(query),
          onEndpointSelected: (endpoint) => ref
              .read(apiDetailStateProvider.notifier)
              .selectEndpoint(endpoint),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        Expanded(
          child: DefaultTabController(
            length: 3,
            initialIndex: detailState.selectedTab,
            child: ApiDetailRightPane(
              selectedEndpoint: selectedEndpoint,
              selectedTab: detailState.selectedTab,
              editableHeaders: detailState.editableHeaders,
              onImportSelected: () {
                final selectedRequestModel = selectedRequestModelAsyncValue
                    .maybeWhen(data: (value) => value, orElse: () => null);
                if (selectedRequestModel == null) {
                  return;
                }
                importRequestModelsToWorkspace(context, ref, <RequestModel>[
                  selectedRequestModel,
                ]);
              },
              onTabChanged: (tabIndex) =>
                  ref.read(apiDetailStateProvider.notifier).selectTab(tabIndex),
              onHeaderKeyChanged: (index, value) => ref
                  .read(apiDetailStateProvider.notifier)
                  .updateHeaderKey(index, value),
              onHeaderValueChanged: (index, value) => ref
                  .read(apiDetailStateProvider.notifier)
                  .updateHeaderValue(index, value),
              onHeaderDeleted: (index) => ref
                  .read(apiDetailStateProvider.notifier)
                  .removeHeaderRow(index),
              onHeaderAdded: () =>
                  ref.read(apiDetailStateProvider.notifier).addHeaderRow(),
            ),
          ),
        ),
      ],
    );
  }
}
