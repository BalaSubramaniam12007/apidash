import 'package:apidash/models/models.dart';
import 'package:apidash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void importRequestModelsToWorkspace(
  BuildContext context,
  WidgetRef ref,
  List<RequestModel> requestModels,
) {
  var importedCount = 0;

  for (final requestModel in requestModels) {
    final httpRequestModel = requestModel.httpRequestModel;
    if (httpRequestModel == null) {
      continue;
    }

    ref
        .read(collectionStateNotifierProvider.notifier)
        .addRequestModel(
          httpRequestModel,
          name: requestModel.name.isNotEmpty ? requestModel.name : null,
        );
    importedCount++;
  }

  if (importedCount == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No importable HTTP requests found.')),
    );
    return;
  }

  ref.read(navRailIndexStateProvider.notifier).state = 0;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Imported $importedCount request(s) to workspace')),
  );
}
