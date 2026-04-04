import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

const double _kApiCardAvatarSize = 26;

class ApiExplorerCard extends StatelessWidget {
  const ApiExplorerCard({super.key, required this.api, required this.onTap});

  final ApiSummary api;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(context, api.category);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: kP12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _CategoryAvatar(
                    name: api.name,
                    color: categoryColor,
                    textStyle: theme.textTheme.labelSmall,
                  ),
                  const Spacer(),
                  _CategoryBadge(
                    category: api.category,
                    color: categoryColor,
                    textStyle: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              kVSpacer10,
              Text(
                api.name,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              kVSpacer3,
              Text(
                '${api.endpointCount} endpoints',
                style: theme.textTheme.bodySmall,
              ),
              kVSpacer8,
              Text(
                api.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({
    required this.name,
    required this.color,
    required this.textStyle,
  });

  final String name;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kApiCardAvatarSize,
      height: _kApiCardAvatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
      ),
      alignment: Alignment.center,
      child: Text(
        name.characters.first.toUpperCase(),
        style: textStyle?.copyWith(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
    required this.color,
    required this.textStyle,
  });

  final String category;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: kBorderRadius20,
        color: color.withValues(alpha: 0.16),
      ),
      child: Text(category, style: textStyle?.copyWith(color: color)),
    );
  }
}

Color _categoryColor(BuildContext context, String category) {
  return switch (category) {
    'AI' => Theme.of(context).colorScheme.secondary,
    'Demo' => Theme.of(context).colorScheme.tertiary,
    'Finance' => Colors.green,
    'Social' => Colors.teal,
    'Test' => Colors.orange,
    'Utilities' => Colors.purple,
    'Weather' => Colors.blue,
    _ => Theme.of(context).colorScheme.primary,
  };
}
