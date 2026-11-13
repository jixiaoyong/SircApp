/// 统一 API 响应包装类
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? message;
  final bool isSuccess;

  const ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, {int statusCode = 200, String? message}) {
    return ApiResponse(
      statusCode: statusCode,
      data: data,
      message: message,
      isSuccess: true,
    );
  }

  factory ApiResponse.failure({
    required int statusCode,
    required String message,
    T? data,
  }) {
    return ApiResponse(
      statusCode: statusCode,
      data: data,
      message: message,
      isSuccess: false,
    );
  }
}
