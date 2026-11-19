import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_response.dart';
import 'network_exception.dart';

/// 基于官方 http 包的统一网络客户端实现
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  HttpApiClient({
    this.baseUrl = '',
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client(),
       defaultHeaders =
           defaultHeaders ??
           {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final fullUrl = path.startsWith('http') ? path : '$baseUrl$path';
    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map(
        (k, v) => MapEntry(k, v.toString()),
      );
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {...defaultHeaders, ...?headers};
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest(
      () => _client.get(
        _buildUri(path, queryParameters),
        headers: _mergeHeaders(headers),
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest(
      () => _client.post(
        _buildUri(path),
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest(
      () => _client.put(
        _buildUri(path),
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    return _sendRequest(
      () => _client.delete(_buildUri(path), headers: _mergeHeaders(headers)),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> _sendRequest<T>(
    Future<http.Response> Function() requestFn, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await requestFn().timeout(timeout);
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse.success(null as T, statusCode: statusCode);
        }
        final dynamic parsed = jsonDecode(response.body);
        final T data = fromJson != null ? fromJson(parsed) : parsed as T;
        return ApiResponse.success(data, statusCode: statusCode);
      } else {
        throw NetworkException.fromStatusCode(
          statusCode,
          'Server returned status $statusCode',
          response.body,
        );
      }
    } on TimeoutException {
      throw NetworkException.timeout();
    } on SocketException {
      throw NetworkException.noInternet();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  void close() {
    _client.close();
  }
}
