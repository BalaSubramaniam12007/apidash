import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

class ApiDetailHeadersTab extends StatelessWidget {
  const ApiDetailHeadersTab({
    super.key,
    required this.headers,
    required this.onHeaderKeyChanged,
    required this.onHeaderValueChanged,
    required this.onHeaderDeleted,
    required this.onHeaderAdded,
  });

  final List<MapEntry<String, String>> headers;

  final void Function(int, String) onHeaderKeyChanged;

  final void Function(int, String) onHeaderValueChanged;

  final ValueChanged<int> onHeaderDeleted;

  final VoidCallback onHeaderAdded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          ..._buildRows(),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onHeaderAdded,
              icon: const Icon(Icons.add),
              label: const Text('Add row'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows() {
    return List<Widget>.generate(headers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _HeaderRow(
          index: index,
          header: headers[index],
          onHeaderKeyChanged: onHeaderKeyChanged,
          onHeaderValueChanged: onHeaderValueChanged,
          onHeaderDeleted: onHeaderDeleted,
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.index,
    required this.header,
    required this.onHeaderKeyChanged,
    required this.onHeaderValueChanged,
    required this.onHeaderDeleted,
  });

  final int index;
  final MapEntry<String, String> header;
  final void Function(int, String) onHeaderKeyChanged;
  final void Function(int, String) onHeaderValueChanged;
  final ValueChanged<int> onHeaderDeleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: header.key,
            onChanged: (value) => onHeaderKeyChanged(index, value),
            decoration: const InputDecoration(hintText: 'Header key'),
          ),
        ),
        kHSpacer8,
        Expanded(
          child: TextFormField(
            initialValue: header.value,
            onChanged: (value) => onHeaderValueChanged(index, value),
            decoration: const InputDecoration(hintText: 'Header value'),
          ),
        ),
        IconButton(
          onPressed: () => onHeaderDeleted(index),
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    );
  }
}
