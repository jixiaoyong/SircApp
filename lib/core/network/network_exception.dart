/// 网络异常类型枚举
enum NetworkErrorType {
  noInternet,
  connectionTimeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}

/// 统一网络异常对象
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkErrorType type;
  final dynamic details;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.type = NetworkErrorType.unknown,
    this.details,
  });

  factory NetworkException.fromStatusCode(
    int code, [
    String? message,
    dynamic details,
  ]) {
    final type = switch (code) {
      400 => NetworkErrorType.badRequest,
      401 => NetworkErrorType.unauthorized,
      403 => NetworkErrorType.forbidden,
      404 => NetworkErrorType.notFound,
      >= 500 => NetworkErrorType.serverError,
      _ => NetworkErrorType.unknown,
    };
    return NetworkException(
      message: message ?? 'Network request failed with status: $code',
      statusCode: code,
      type: type,
      details: details,
    );
  }

  factory NetworkException.noInternet([String? message]) {
    return NetworkException(
      message: message ?? 'No active internet connection found',
      type: NetworkErrorType.noInternet,
    );
  }

  factory NetworkException.timeout([String? message]) {
    return NetworkException(
      message: message ?? 'Request connection timed out',
      type: NetworkErrorType.connectionTimeout,
    );
  }

  @override
  String toString() => 'NetworkException($statusCode, $type): $message';
}
