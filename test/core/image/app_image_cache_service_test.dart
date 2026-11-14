import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/image/app_image_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return '/tmp';
      }
      return null;
    });
  });

  tearDown(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AppImageCacheService Tests', () {
    test('Format bytes accurately across scales', () {
      expect(AppImageCacheService.formatBytes(0), '0 B');
      expect(AppImageCacheService.formatBytes(-5), '0 B');
      expect(AppImageCacheService.formatBytes(512), '512 B');
      expect(AppImageCacheService.formatBytes(1024), '1.0 KB');
      expect(AppImageCacheService.formatBytes(1536), '1.5 KB');
      expect(AppImageCacheService.formatBytes(1024 * 1024), '1.00 MB');
      expect(AppImageCacheService.formatBytes((2.5 * 1024 * 1024).round()), '2.50 MB');
      expect(AppImageCacheService.formatBytes(1024 * 1024 * 1024), '1.00 GB');
    });

    test('Downsampling calculation respects pixel ratio and clamps', () {
      expect(AppImageCacheService.computeCacheDimension(logicalSize: null), isNull);
      expect(AppImageCacheService.computeCacheDimension(logicalSize: 0), isNull);
      expect(AppImageCacheService.computeCacheDimension(logicalSize: -10), isNull);

      // 48.0 logical @ 2.0x = 96 px
      final d96 = AppImageCacheService.computeCacheDimension(
        logicalSize: 48.0,
        devicePixelRatio: 2.0,
      );
      expect(d96, 96);

      // Clamp to minDimension
      final dMin = AppImageCacheService.computeCacheDimension(
        logicalSize: 10.0,
        devicePixelRatio: 1.0,
        minDimension: 32,
      );
      expect(dMin, 32);

      // Clamp to maxDimension
      final dMax = AppImageCacheService.computeCacheDimension(
        logicalSize: 3000.0,
        devicePixelRatio: 2.0,
        maxDimension: 2048,
      );
      expect(dMax, 2048);
    });

    test('L1 Memory Cache limits and clear operation execute without error', () {
      final service = AppImageCacheService.instance;
      service.configureMemoryLimits(maxCount: 800, maxBytes: 50 * 1024 * 1024);
      expect(service.memoryMaxCount, 800);
      expect(service.memoryMaxBytes, 50 * 1024 * 1024);

      service.clearMemory();
      expect(service.memoryCount, isA<int>());
      expect(service.memoryBytes, isA<int>());
    });

    test('L2 Disk Cache operations execute safely', () async {
      final service = AppImageCacheService.instance;
      final bytes = await service.getDiskCachedBytes();
      expect(bytes, isA<int>());

      final cleared = await service.clearDiskCache();
      expect(cleared, isTrue);

      await service.clearAll();
      expect(service.memoryCount, isA<int>());
    });
  });
}
