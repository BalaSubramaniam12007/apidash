import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:json_explorer/json_explorer.dart';

import '../consts.dart';
import 'field_json_search.dart';

class JsonPreviewerToolbar extends StatelessWidget {
  const JsonPreviewerToolbar({
    super.key,
    required this.searchController,
    required this.store,
    required this.constraints,
    required this.onFocusPrevious,
    required this.onFocusNext,
  });

  final TextEditingController searchController;

  final JsonExplorerStore store;

  final BoxConstraints constraints;

  final VoidCallback onFocusPrevious;

  final VoidCallback onFocusNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              borderRadius: kBorderRadius8,
            ),
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: kPh4,
                  child: Icon(Icons.search, size: 16),
                ),
                Expanded(
                  child: JsonSearchField(
                    controller: searchController,
                    onChanged: store.search,
                  ),
                ),
                const SizedBox(width: 8),
                if (store.searchResults.isNotEmpty)
                  Text(
                    '${store.focusedSearchResultIndex + 1}/${store.searchResults.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (store.searchResults.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onFocusPrevious,
                    icon: const Icon(Icons.arrow_drop_up),
                  ),
                if (store.searchResults.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onFocusNext,
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
              ],
            ),
          ),
        ),
        ADTextButton(
          icon: Icons.unfold_more,
          showLabel:
              (constraints.minWidth > kMinWindowSize.width) && !kIsMobile,
          label: 'Expand All',
          labelTextStyle: kTextStyleButtonSmall,
          onPressed: store.areAllExpanded() ? null : store.expandAll,
        ),
        ADTextButton(
          icon: Icons.unfold_less,
          showLabel:
              (constraints.minWidth > kMinWindowSize.width) && !kIsMobile,
          label: 'Collapse All',
          labelTextStyle: kTextStyleButtonSmall,
          onPressed: store.areAllCollapsed() ? null : store.collapseAll,
        ),
      ],
    );
  }
}
