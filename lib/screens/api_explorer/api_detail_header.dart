import 'package:apidash/models/models.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

const double _kApiDetailHeaderHeight = 56;
const double _kApiDetailVersionDropdownMaxWidth = 160;

class ApiDetailHeader extends StatelessWidget {
  const ApiDetailHeader({
    super.key,
    required this.apiSummary,
    required this.versions,
    required this.selectedVersion,
    required this.onVersionChanged,
    required this.onImportAll,
    required this.onBack,
  });

  final ApiSummary apiSummary;

  final List<String> versions;

  final String? selectedVersion;

  final ValueChanged<String?> onVersionChanged;

  final VoidCallback onImportAll;

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kApiDetailHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          kHSpacer6,
          Expanded(child: _HeaderTitle(apiSummary: apiSummary)),
          _VersionSelector(
            versions: versions,
            selectedVersion: selectedVersion,
            onVersionChanged: onVersionChanged,
          ),
          kHSpacer8,
          ImportButton(
            label: 'Import',
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            onPressed: onImportAll,
          ),
          kHSpacer8,
          ImportButton(
            label: 'Import All',
            size: ButtonSize.small,
            leadingIcon: Icons.download_outlined,
            onPressed: onImportAll,
          ),
        ],
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.apiSummary});

  final ApiSummary apiSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(apiSummary.name, style: Theme.of(context).textTheme.titleSmall),
        Text(
          'Standard OpenAPI sample service',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _VersionSelector extends StatelessWidget {
  const _VersionSelector({
    required this.versions,
    required this.selectedVersion,
    required this.onVersionChanged,
  });

  final List<String> versions;
  final String? selectedVersion;
  final ValueChanged<String?> onVersionChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _kApiDetailVersionDropdownMaxWidth,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedVersion,
        items: versions
            .map(
              (version) => DropdownMenuItem<String>(
                value: version,
                child: Text(version, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: onVersionChanged,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
