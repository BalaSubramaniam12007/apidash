import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({
    super.key,
    required this.networkLabel,
    required this.networkConnected,
    required this.latencyLabel,
    required this.systemStateLabel,
  });

  final String networkLabel;

  final bool networkConnected;

  final String latencyLabel;

  final String systemStateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
        ),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.circle,
            size: 8,
            color: networkConnected
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          kHSpacer6,
          Text(networkLabel, style: theme.textTheme.labelSmall),
          const Spacer(),
          Text(latencyLabel, style: theme.textTheme.labelSmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: kBorderRadius20,
            ),
            child: Text(
              systemStateLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
