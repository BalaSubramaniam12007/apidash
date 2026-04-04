import 'package:flutter/material.dart';

const int _kExplorerSimplePaginationLimit = 5;

class ExplorerFooter extends StatelessWidget {
  const ExplorerFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;

  final int totalPages;

  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(totalPages);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...pages.map(
            (page) => page == null
                ? _PaginationEllipsis(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                  )
                : _PaginationButton(
                    page: page,
                    currentPage: currentPage,
                    onPressed: () => onPageChanged(page),
                  ),
          ),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.page,
    required this.currentPage,
    required this.onPressed,
  });

  final int page;
  final int currentPage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
          foregroundColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : null,
          minimumSize: const Size(34, 34),
          padding: EdgeInsets.zero,
        ),
        child: Text('$page'),
      ),
    );
  }
}

class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis({required this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('...', style: textStyle),
    );
  }
}

List<int?> _buildPages(int totalPages) {
  if (totalPages <= _kExplorerSimplePaginationLimit) {
    return List<int?>.generate(totalPages, (index) => index + 1);
  }
  return <int?>[1, 2, 3, null, totalPages];
}
