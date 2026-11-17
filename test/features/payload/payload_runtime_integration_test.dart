import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 管理器的传递依赖，仅用来构造本地 ZIP 测试夹具。
// ignore: depend_on_referenced_packages
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/payload/payload_runtime_io.dart';
import 'package:web_payload_manager/web_payload_manager.dart';

Future<void> _until(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) fail('资源状态等待超时');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<String> _read(String url, String userAgent) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'Native-UA $userAgent');
    final response = await request.close();
    expect(response.statusCode, HttpStatus.ok);
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manager = WebPayloadManager.getInstance();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory directory;
  HttpOverrides? previousOverrides;

  test('宿主默认版本与 pubspec 一致', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(payloadHostAppVersion, version);
  });

  setUp(() async {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    directory = await Directory.systemTemp.createTemp('sirc_payload_');
    messenger.setMockMethodCallHandler(channel, (_) async => directory.path);
    // 使用宿主真实内置文件，验证清单与 asset 同步，而非手工预置 default。
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'AssetManifest.json') {
        return ByteData.sublistView(
          utf8.encode(
            jsonEncode({
              'assets/web_payload/version.json': [],
              'assets/web_payload/companion/index.html': [],
            }),
          ),
        );
      }
      final file = File(key);
      return await file.exists()
          ? ByteData.sublistView(await file.readAsBytes())
          : null;
    });
  });

  tearDown(() async {
    await manager.dispose();
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMessageHandler('flutter/assets', null);
    await directory.delete(recursive: true);
    HttpOverrides.global = previousOverrides;
  });

  test('空更新地址纯内置初始化，无在线同步且本地页面真实可读', () async {
    final runtime = createPayloadRuntime(updateUrl: '');
    try {
      await runtime.start();
      expect(runtime.failed, isFalse);
      await _until(() => runtime.url != null);
      expect(runtime.version, '1.0.0');
      expect(runtime.syncStatus, 'idle');
      expect(runtime.availableVersion, isNull);
      expect(
        await _read(runtime.url!, runtime.authUserAgent),
        contains('sircPresentation'),
      );
      await runtime.resume();
      expect(
        await _read(runtime.url!, runtime.authUserAgent),
        contains('1.0.0'),
      );
    } finally {
      runtime.dispose();
    }
  });

  test('真实 ZIP 后台就绪不切换，显式激活后重载且旧 URL 内容稳定', () async {
    final html = '<!doctype html><html><body>updated-1.1.0</body></html>';
    final htmlBytes = utf8.encode(html);
    final archive = Archive();
    final files = {
      'version.json': jsonEncode({
        'version': '1.1.0',
        'modules': [
          {'key': 'companion', 'entryHtml': 'companion/index.html'},
        ],
        'fileInfo': {
          'total_files': 1,
          'files': [
            {
              'path': 'companion/index.html',
              'md5': md5.convert(htmlBytes).toString(),
            },
          ],
        },
      }),
      'companion/index.html': html,
    };
    for (final entry in files.entries) {
      final bytes = utf8.encode(entry.value);
      archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
    }
    final zip = ZipEncoder().encode(archive);
    final gate = Completer<void>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var manifestRequests = 0;
    var zipRequests = 0;
    server.listen((request) async {
      if (request.uri.path == '/version.json') {
        manifestRequests++;
        await gate.future;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'version': '1.1.0',
            'minAppVersion': payloadHostAppVersion,
            'downloadUrl': 'http://127.0.0.1:${server.port}/payload.zip',
            'md5': md5.convert(zip).toString(),
          }),
        );
      } else if (request.uri.path == '/payload.zip') {
        zipRequests++;
        request.response.add(zip);
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });
    final runtime = createPayloadRuntime(
      updateUrl: 'http://127.0.0.1:${server.port}/version.json',
    );
    try {
      await runtime.start();
      await _until(() => runtime.url != null);
      final oldUrl = runtime.url!;
      final oldUa = runtime.authUserAgent;
      final oldHtml = await _read(oldUrl, oldUa);
      expect(runtime.version, '1.0.0');
      expect(oldUrl, contains('/__payload/'));
      gate.complete();
      await _until(() => runtime.availableVersion == '1.1.0');
      expect(runtime.url, oldUrl);
      expect(runtime.version, '1.0.0');
      expect(await _read(oldUrl, oldUa), oldHtml);
      // 普通重试、恢复前台都不能绕过用户手动激活。
      await runtime.retry();
      await runtime.resume();
      expect(runtime.url, oldUrl);
      await runtime.activateUpdate();
      await _until(() => runtime.version == '1.1.0');
      expect(runtime.url, isNot(oldUrl));
      expect(runtime.availableVersion, isNull);
      expect(runtime.authUserAgent, isNotEmpty);
      expect(await _read(runtime.url!, runtime.authUserAgent), html);
      expect(await _read(oldUrl, runtime.authUserAgent), oldHtml);
      expect(manifestRequests, 1);
      expect(zipRequests, 1);
    } finally {
      if (!gate.isCompleted) gate.complete();
      runtime.dispose();
      await server.close(force: true);
    }
  });
}
