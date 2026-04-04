import 'dart:convert';

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

const String _kApiExplorerServiceLogPrefix = '[ApiExplorerService]';

class ApiExplorerService {
  ApiExplorerService({String? repository})
    : repository =
          repository ??
          const String.fromEnvironment(
            'API_EXPLORER_REPO',
            defaultValue: 'BalaSubramaniam12007/api-explorer-mvp',
          );

  static const Duration _pointerTtl = Duration(minutes: 5);
  static const int _pointerMaxRetries = 3;
  static const Duration _pointerRetryDelay = Duration(seconds: 5);
  static const Duration _requestTimeout = Duration(seconds: 20);

  final String repository;

  String get _repoBase => 'https://cdn.jsdelivr.net/gh/$repository';

  String? _cachedSha;
  DateTime? _cachedShaAt;

  Future<String> getLatestSha() async {
    final now = DateTime.now();
    final cachedSha = _cachedSha;
    final cachedShaAt = _cachedShaAt;

    if (cachedSha != null &&
        cachedShaAt != null &&
        now.difference(cachedShaAt) < _pointerTtl) {
      return cachedSha;
    }

    final pointerUrl = '$_repoBase@main/api_templates/current.json';
    for (var attempt = 1; attempt <= _pointerMaxRetries; attempt++) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      try {
        final pointerData = await _getJsonMap(
          '$pointerUrl?t=$timestamp',
          noStore: true,
        );
        final sha = pointerData['sha']?.toString().trim();
        if (sha != null && sha.isNotEmpty) {
          _cachedSha = sha;
          _cachedShaAt = now;
          return sha;
        }
      } catch (error) {
        final isLastAttempt = attempt == _pointerMaxRetries;
        debugPrint(
          '$_kApiExplorerServiceLogPrefix Failed to resolve SHA '
          '(attempt $attempt/$_pointerMaxRetries): $error',
        );
        if (isLastAttempt) {
          throw Exception('Unable to resolve latest API Explorer SHA: $error');
        }
        await Future<void>.delayed(_pointerRetryDelay);
      }
    }

    debugPrint('$_kApiExplorerServiceLogPrefix Unable to resolve latest SHA.');
    throw Exception('Unable to resolve latest API Explorer SHA');
  }

  Future<Map<String, dynamic>> getGlobalIndex(String sha) async {
    return _getJsonMap('$_repoBase@$sha/api_templates/global_index.json');
  }

  Future<Map<String, dynamic>> getApiMeta(String sha, String apiId) async {
    return getApiIndex(sha, apiId);
  }

  Future<Map<String, dynamic>> getApiIndex(String sha, String apiId) async {
    return _getJsonMap('$_repoBase@$sha/api_templates/apis/$apiId/index.json');
  }

  Future<Map<String, dynamic>> getApiTemplate(String sha, String apiId) async {
    final payload = await _getJsonValue(
      '$_repoBase@$sha/api_templates/apis/$apiId/template.json',
    );
    return _normalizeTemplatePayload(payload, apiId: apiId);
  }

  Future<Map<String, dynamic>> getTemplates({
    required String sha,
    required String apiId,
    required String version,
  }) async {
    final templateUrls = <String>[
      '$_repoBase@$sha/api_templates/apis/$apiId/template.json',
      '$_repoBase@$sha/api_templates/apis/$apiId/$version/template.json',
      '$_repoBase@$sha/api_templates/apis/$apiId/$version/templates.json',
    ];

    Object? lastError;
    for (final templateUrl in templateUrls) {
      try {
        final payload = await _getJsonValue(templateUrl);
        return _normalizeTemplatePayload(payload, apiId: apiId);
      } catch (error) {
        lastError = error;
        debugPrint(
          '$_kApiExplorerServiceLogPrefix Failed template URL '
          '$templateUrl: $error',
        );
      }
    }

    debugPrint(
      '$_kApiExplorerServiceLogPrefix Unable to fetch templates for '
      '$apiId:$version (${lastError ?? 'unknown error'}).',
    );
    throw Exception(
      'Unable to fetch templates for $apiId:$version '
      '(${lastError ?? 'unknown error'})',
    );
  }

  Future<Object?> _getJsonValue(String url, {bool noStore = false}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (noStore) {
      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
      headers['Pragma'] = 'no-cache';
      headers['Expires'] = '0';
    }

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(_requestTimeout);

    if (response.statusCode == 404) {
      debugPrint('$_kApiExplorerServiceLogPrefix HTTP 404 for $url');
      throw Exception('HTTP 404 for $url');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '$_kApiExplorerServiceLogPrefix HTTP ${response.statusCode} for $url',
      );
      throw Exception('HTTP ${response.statusCode} for $url');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> _getJsonMap(
    String url, {
    bool noStore = false,
  }) async {
    final decodedPayload = await _getJsonValue(url, noStore: noStore);
    if (decodedPayload is! Map<String, dynamic>) {
      debugPrint(
        '$_kApiExplorerServiceLogPrefix Invalid JSON object from $url',
      );
      throw Exception('Invalid JSON object from $url');
    }
    return decodedPayload;
  }

  Map<String, dynamic> _normalizeTemplatePayload(
    Object? payload, {
    required String apiId,
  }) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is List) {
      return <String, dynamic>{'requests': payload};
    }
    debugPrint(
      '$_kApiExplorerServiceLogPrefix Invalid template payload for '
      'apiId=$apiId type=${payload.runtimeType}',
    );
    throw Exception('Invalid template payload for apiId=$apiId');
  }
}
