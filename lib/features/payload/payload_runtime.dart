import 'package:flutter/foundation.dart';

/// 宿主离线包更新清单地址。
///
/// 默认指向 GitHub Pages 托管的线上版本清单，也可在构建或运行时通过
/// `--dart-define=SIRC_PAYLOAD_UPDATE_URL=<url>` 自定义覆盖（如指向本地开发测试服务）。
const payloadUpdateUrl = String.fromEnvironment(
  'SIRC_PAYLOAD_UPDATE_URL',
  defaultValue:
      'https://jixiaoyong.github.io/SircApp/payload/server_manifest.json',
);

/// 与平台无关的资源会话，隔离管理器的 dart:io 依赖。
abstract class PayloadRuntime extends ChangeNotifier {
  String? url;
  String authUserAgent = '';
  bool failed = false;
  String syncStatus = 'idle';
  String? version;
  String? availableVersion;

  /// 用户确认后激活就绪包；不会由后台同步事件自动调用。
  Future<void> activateUpdate();

  /// 初始化本地服务并在配置更新地址时后台检查更新。
  Future<void> start();

  /// 重试本地资源；[restore] 为 true 时切回内置版本。
  Future<void> retry({bool restore = false});

  /// 恢复前台时检查服务与鉴权会话。
  Future<void> resume();
}

/// 仅允许当前本地服务的同源页面留在 WebView。
/// [target] 为目标 URI，[local] 为当前资源入口。
bool isPayloadNavigation(Uri target, Uri local) =>
    target.scheme == local.scheme &&
    target.host == local.host &&
    target.port == local.port &&
    target.userInfo.isEmpty;
