import 'package:apidash/models/models.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';

const double _kApiDetailLeftPaneWidth = 260;

class ApiDetailLeftPane extends StatelessWidget {
  const ApiDetailLeftPane({
    super.key,
    required this.endpoints,
    required this.selectedEndpoint,
    required this.onSearchChanged,
    required this.onEndpointSelected,
  });

  final List<Endpoint> endpoints;

  final Endpoint? selectedEndpoint;

  final ValueChanged<String> onSearchChanged;

  final ValueChanged<Endpoint> onEndpointSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kApiDetailLeftPaneWidth,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchField(
              hintText: 'Filter endpoints...',
              onChanged: onSearchChanged,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final endpoint = endpoints[index];
                final isSelected = selectedEndpoint?.id == endpoint.id;
                return _EndpointTile(
                  endpoint: endpoint,
                  isSelected: isSelected,
                  onTap: () => onEndpointSelected(endpoint),
                );
              },
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              itemCount: endpoints.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({
    required this.endpoint,
    required this.isSelected,
    required this.onTap,
  });

  final Endpoint endpoint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MethodBadge(method: endpoint.method),
              kHSpacer8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      endpoint.path,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      endpoint.summary,
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
