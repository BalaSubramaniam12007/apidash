import 'package:apidash/widgets/widgets.dart';
import 'package:flutter/material.dart';

const EdgeInsets _kExplorerHeaderPadding = EdgeInsets.fromLTRB(16, 16, 16, 12);

class ExplorerHeader extends StatelessWidget {
  const ExplorerHeader({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterSelected,
  });

  final List<String> filters;

  final String? selectedFilter;

  final ValueChanged<String> onSearchChanged;

  final ValueChanged<String?> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kExplorerHeaderPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SearchField(hintText: 'Search APIs...', onChanged: onSearchChanged),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters
                .map(
                  (filter) => ChoiceChip(
                    label: Text(filter),
                    selected: (selectedFilter ?? 'All') == filter,
                    onSelected: (_) =>
                        onFilterSelected(filter == 'All' ? null : filter),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
