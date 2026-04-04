import 'dart:convert';

import 'package:apidash/models/models.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

import 'api_detail_headers_tab.dart';

class ApiDetailTabPanels extends StatelessWidget {
  const ApiDetailTabPanels({
    super.key,
    required this.selectedTab,
    required this.endpoint,
    required this.editableHeaders,
    required this.onHeaderKeyChanged,
    required this.onHeaderValueChanged,
    required this.onHeaderDeleted,
    required this.onHeaderAdded,
  });

  final int selectedTab;

  final Endpoint endpoint;

  final List<MapEntry<String, String>> editableHeaders;

  final void Function(int, String) onHeaderKeyChanged;

  final void Function(int, String) onHeaderValueChanged;

  final ValueChanged<int> onHeaderDeleted;

  final VoidCallback onHeaderAdded;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedTab,
      children: <Widget>[
        _ParamsTab(endpoint: endpoint),
        _AuthTab(endpoint: endpoint),
        ApiDetailHeadersTab(
          headers: editableHeaders,
          onHeaderKeyChanged: onHeaderKeyChanged,
          onHeaderValueChanged: onHeaderValueChanged,
          onHeaderDeleted: onHeaderDeleted,
          onHeaderAdded: onHeaderAdded,
        ),
      ],
    );
  }
}

class _ParamsTab extends StatelessWidget {
  const _ParamsTab({required this.endpoint});

  final Endpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final payload = const JsonEncoder.withIndent(
      '  ',
    ).convert(endpoint.samplePayload);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SelectableText(payload, style: kCodeStyle),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({required this.endpoint});

  final Endpoint endpoint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Authorization for ${endpoint.path} is inherited from API defaults.',
      ),
    );
  }
}
