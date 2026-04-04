import 'http_method.dart';

class Endpoint {
  const Endpoint({
    required this.id,
    required this.method,
    required this.path,
    required this.summary,
    required this.headers,
    required this.samplePayload,
  });

  final String id;

  final HttpMethod method;

  final String path;

  final String summary;

  final Map<String, String> headers;

  final Map<String, dynamic> samplePayload;
}
