import 'package:apidash/models/models.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

import 'api_detail_payload_panel.dart';
import 'api_detail_tab_panels.dart';

class ApiDetailRightPane extends StatelessWidget {
  const ApiDetailRightPane({
    super.key,
    required this.selectedEndpoint,
    required this.selectedTab,
    required this.editableHeaders,
    required this.onImportSelected,
    required this.onTabChanged,
    required this.onHeaderKeyChanged,
    required this.onHeaderValueChanged,
    required this.onHeaderDeleted,
    required this.onHeaderAdded,
  });

  final Endpoint? selectedEndpoint;

  final int selectedTab;

  final List<MapEntry<String, String>> editableHeaders;

  final VoidCallback onImportSelected;

  final ValueChanged<int> onTabChanged;

  final void Function(int, String) onHeaderKeyChanged;

  final void Function(int, String) onHeaderValueChanged;

  final ValueChanged<int> onHeaderDeleted;

  final VoidCallback onHeaderAdded;

  @override
  Widget build(BuildContext context) {
    final endpoint = selectedEndpoint;
    if (endpoint == null) {
      return const Center(child: Text('Select an endpoint to inspect'));
    }

    return Column(
      children: <Widget>[
        _EndpointSummaryRow(
          endpoint: endpoint,
          onImportSelected: onImportSelected,
        ),
        _EndpointPathRow(endpoint: endpoint),
        TabBar(
          onTap: onTabChanged,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const <Tab>[
            Tab(text: 'Params'),
            Tab(text: 'Auth'),
            Tab(text: 'Headers'),
          ],
        ),
        Expanded(
          child: ApiDetailTabPanels(
            selectedTab: selectedTab,
            endpoint: endpoint,
            editableHeaders: editableHeaders,
            onHeaderKeyChanged: onHeaderKeyChanged,
            onHeaderValueChanged: onHeaderValueChanged,
            onHeaderDeleted: onHeaderDeleted,
            onHeaderAdded: onHeaderAdded,
          ),
        ),
        Expanded(child: ApiDetailPayloadPanel(endpoint: endpoint)),
      ],
    );
  }
}

class _EndpointSummaryRow extends StatelessWidget {
  const _EndpointSummaryRow({
    required this.endpoint,
    required this.onImportSelected,
  });

  final Endpoint endpoint;
  final VoidCallback onImportSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: <Widget>[
          MethodBadge(method: endpoint.method),
          kHSpacer8,
          Expanded(
            child: Text(
              endpoint.summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          kHSpacer12,
          ImportButton(label: 'Import', onPressed: onImportSelected),
        ],
      ),
    );
  }
}

class _EndpointPathRow extends StatelessWidget {
  const _EndpointPathRow({required this.endpoint});

  final Endpoint endpoint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: kBorderRadius8,
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Row(
          children: <Widget>[
            MethodBadge(method: endpoint.method),
            kHSpacer8,
            Expanded(
              child: Text(
                endpoint.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kCodeStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
