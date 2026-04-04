import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class MethodBadge extends StatelessWidget {
  const MethodBadge({super.key, required this.method});

  final HttpMethod method;

  @override
  Widget build(BuildContext context) {
    final color = _methodColor(context, method);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: kBorderRadius20,
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        method.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

Color _methodColor(BuildContext context, HttpMethod method) {
  return switch (method) {
    HttpMethod.get => kColorHttpMethodPost,
    HttpMethod.post => kColorHttpMethodGet,
    HttpMethod.put => kColorHttpMethodPut,
    HttpMethod.delete => kColorHttpMethodDelete,
    HttpMethod.patch => Theme.of(context).colorScheme.outline,
  };
}
