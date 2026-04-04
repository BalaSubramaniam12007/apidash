import 'dart:convert';

import 'package:apidash/models/models.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

class ApiDetailPayloadPanel extends StatelessWidget {
  const ApiDetailPayloadPanel({super.key, required this.endpoint});

  final Endpoint endpoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: <Widget>[
              Text(
                'Sample Payload Content',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: kBorderRadius8,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  const JsonEncoder.withIndent(
                    '  ',
                  ).convert(endpoint.samplePayload),
                  style: kCodeStyle,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Text(
                'Preview only — Import to test',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
