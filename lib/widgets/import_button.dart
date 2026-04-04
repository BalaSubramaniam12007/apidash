import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, outline }

enum ButtonSize { normal, small }

class ImportButton extends StatelessWidget {
  const ImportButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.normal,
    this.leadingIcon,
  });

  final String label;

  final VoidCallback? onPressed;

  final ButtonVariant variant;

  final ButtonSize size;

  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == ButtonVariant.primary;
    final height = size == ButtonSize.small ? 32.0 : 40.0;

    return SizedBox(
      height: height,
      child: isPrimary
          ? FilledButton(onPressed: onPressed, child: _buildChild(context))
          : OutlinedButton(onPressed: onPressed, child: _buildChild(context)),
    );
  }

  Widget _buildChild(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (leadingIcon != null) Icon(leadingIcon, size: 16),
        if (leadingIcon != null) kHSpacer6,
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
