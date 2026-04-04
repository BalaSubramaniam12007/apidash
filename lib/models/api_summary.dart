class ApiSummary {
  const ApiSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.endpointCount,
    required this.category,
    this.iconAsset,
  });

  final String id;
  final String name;

  final String description;

  final int endpointCount;

  final String category;

  final String? iconAsset;
}
