import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unbroken_mobile/core/env/app_env.dart';
import 'package:unbroken_mobile/services/http/alice.dart';
import 'package:unbroken_mobile/services/logging/app_log.dart';

part 'urls.dart';

part 'interceptors/retry_interceptor.dart';

abstract class BaseApi {
  final String baseUrl;
  late final http.Client client;

  BaseApi(this.baseUrl, {http.Client? customClient}) {
    http.Client baseClient = customClient ?? http.Client();
    if (!Env.current.isProdRelease) {
      baseClient = AppAlice.ins.getHttpClient(baseClient);
    }
    client = _createRetryClient(baseClient);
  }

  /// Default headers sent with requests.
  Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Default timeout for requests.
  Duration get defaultTimeout => 1.minutes;

  /// Resolves a path (relative or absolute) and optional query parameters to a [Uri].
  Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse(
      path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '$baseUrl${path.startsWith('/') ? path : '/$path'}',
    );
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...queryParameters.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        },
      );
    }
    return uri;
  }

  /// Performs an HTTP GET request.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final uri = buildUri(path, queryParameters);
    final mergedHeaders = {...defaultHeaders, ...?headers};
    return await client
        .get(uri, headers: mergedHeaders)
        .timeout(timeout ?? defaultTimeout);
  }

  /// Performs an HTTP POST request.
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final uri = buildUri(path, queryParameters);
    final mergedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = _encodeBody(body, mergedHeaders);
    return await client
        .post(uri, headers: mergedHeaders, body: encodedBody)
        .timeout(timeout ?? defaultTimeout);
  }

  /// Performs an HTTP PUT request.
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final uri = buildUri(path, queryParameters);
    final mergedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = _encodeBody(body, mergedHeaders);
    return await client
        .put(uri, headers: mergedHeaders, body: encodedBody)
        .timeout(timeout ?? defaultTimeout);
  }

  /// Performs an HTTP PATCH request.
  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final uri = buildUri(path, queryParameters);
    final mergedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = _encodeBody(body, mergedHeaders);
    return await client
        .patch(uri, headers: mergedHeaders, body: encodedBody)
        .timeout(timeout ?? defaultTimeout);
  }

  /// Performs an HTTP DELETE request.
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final uri = buildUri(path, queryParameters);
    final mergedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = _encodeBody(body, mergedHeaders);
    return await client
        .delete(uri, headers: mergedHeaders, body: encodedBody)
        .timeout(timeout ?? defaultTimeout);
  }

  /// Encodes request payload to JSON if [body] is Map or List and content-type is JSON.
  Object? _encodeBody(Object? body, Map<String, String> headers) {
    if (body == null) return null;
    final contentType =
        headers['Content-Type'] ?? headers['content-type'] ?? '';
    if (contentType.contains('application/json') &&
        (body is Map || body is List)) {
      return jsonEncode(body);
    }
    return body;
  }
}

class Api extends BaseApi {
  Api({super.customClient}) : super(URLs.base);
}
