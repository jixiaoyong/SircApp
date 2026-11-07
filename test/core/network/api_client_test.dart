import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/network/api_response.dart';
import 'package:sirc/core/network/mock_api_client.dart';
import 'package:sirc/core/network/network_exception.dart';

void main() {
  group('NetworkException & ApiResponse Tests', () {
    test('NetworkException parses HTTP status codes correctly', () {
      final unauthorized = NetworkException.fromStatusCode(401);
      expect(unauthorized.type, NetworkErrorType.unauthorized);
      expect(unauthorized.statusCode, 401);

      final serverError = NetworkException.fromStatusCode(500);
      expect(serverError.type, NetworkErrorType.serverError);

      final noInternet = NetworkException.noInternet();
      expect(noInternet.type, NetworkErrorType.noInternet);

      final timeout = NetworkException.timeout();
      expect(timeout.type, NetworkErrorType.connectionTimeout);
    });

    test('ApiResponse builds success and failure models', () {
      final success = ApiResponse.success({'id': 123}, statusCode: 200);
      expect(success.isSuccess, isTrue);
      expect(success.data?['id'], 123);

      final failure = ApiResponse<dynamic>.failure(statusCode: 400, message: 'Invalid param');
      expect(failure.isSuccess, isFalse);
      expect(failure.message, 'Invalid param');
    });
  });

  group('MockApiClient Tests', () {
    test('MockApiClient registers and retrieves mock data', () async {
      final client = MockApiClient(simulatedDelay: Duration.zero);
      client.registerMockResponse('/api/balance', {'amount': 35.269});

      final response = await client.get<Map<String, dynamic>>('/api/balance');
      expect(response.isSuccess, isTrue);
      expect(response.data?['amount'], 35.269);
    });

    test('MockApiClient handles POST and custom fromJson converter', () async {
      final client = MockApiClient(simulatedDelay: Duration.zero);
      final response = await client.post<String>(
        '/api/echo',
        body: {'text': 'hello'},
        fromJson: (json) => json['text'] as String,
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, 'hello');
    });
  });
}
