import 'payload_runtime.dart';
import 'payload_runtime_stub.dart'
    if (dart.library.io) 'payload_runtime_io.dart'
    as platform;

/// 应用级会话：切换 Tab 时不释放本地服务。
final PayloadRuntime? payloadRuntime = platform.createPayloadRuntime();

/// runApp 后启动，不阻塞原生首页或认证流程。
Future<void> startPayloadService() async {
  await payloadRuntime?.start();
}
