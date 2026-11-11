import 'dart:async';

import 'api_client.dart';
import 'api_response.dart';

/// 用于离线演示、本地测试的 Mock 客户端实现
class MockApiClient implements ApiClient {
  final Duration simulatedDelay;
  final Map<String, dynamic> _mockResponses = {};

  MockApiClient({this.simulatedDelay = const Duration(milliseconds: 50)});

  /// 预注册 Mock 响应数据
  void registerMockResponse(String path, dynamic data) {
    _mockResponses[path] = data;
  }

  Future<void> _delay() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    await _delay();
    final raw = _mockResponses[path];
    final T data = (fromJson != null && raw != null) ? fromJson(raw) : raw as T;
    return ApiResponse.success(data);
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    await _delay();
    final raw = _mockResponses[path] ?? body;
    final T data = (fromJson != null && raw != null) ? fromJson(raw) : raw as T;
    return ApiResponse.success(data);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    await _delay();
    final raw = _mockResponses[path] ?? body;
    final T data = (fromJson != null && raw != null) ? fromJson(raw) : raw as T;
    return ApiResponse.success(data);
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    await _delay();
    return ApiResponse.success(null as T);
  }
}
