import 'package:apidash/models/models.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

const double _kExplorerGridBreakpoint = 600;
const double _kExplorerCardAspectRatio = 1.85;

class ExplorerBody extends StatelessWidget {
  const ExplorerBody({super.key, required this.apis, required this.onTap});

  final List<ApiSummary> apis;

  final ValueChanged<ApiSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (apis.isEmpty) {
      return const _ExplorerEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= _kExplorerGridBreakpoint
            ? 2
            : 1;
        return GridView.builder(
          key: const PageStorageKey<String>('api-explorer-grid'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemCount: apis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _kExplorerCardAspectRatio,
          ),
          itemBuilder: (context, index) {
            final apiSummary = apis[index];
            return ApiExplorerCard(
              api: apiSummary,
              onTap: () => onTap(apiSummary),
            );
          },
        );
      },
    );
  }
}

class _ExplorerEmptyState extends StatelessWidget {
  const _ExplorerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          kVSpacer10,
          Text('No APIs found', style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
