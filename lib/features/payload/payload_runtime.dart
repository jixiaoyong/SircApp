import 'package:flutter/foundation.dart';

/// 宿主更新地址；留空时禁止在线请求，仅使用内置包。
const payloadUpdateUrl = String.fromEnvironment('SIRC_PAYLOAD_UPDATE_URL');

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
