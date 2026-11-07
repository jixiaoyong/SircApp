import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_response.dart';
import 'http_api_client.dart';
import 'mock_api_client.dart';

/// 统一网络请求客户端抽象接口
abstract class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  });
}

/// ApiClient Provider：默认提供基于真实 HTTP 的 HttpApiClient，并配置可插拔的 Mock 兜底
final apiClientProvider = Provider<ApiClient>((ref) {
  // 当前返回标准统一 HttpApiClient，可通过 overrideWithValue 替换为 MockApiClient
  return HttpApiClient();
});

/// 专供测试与离线演示使用的 MockApiClient Provider
final mockApiClientProvider = Provider<MockApiClient>((ref) {
  return MockApiClient();
});
