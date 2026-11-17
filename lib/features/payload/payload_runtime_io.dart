import 'dart:async';

import 'package:web_payload_manager/web_payload_manager.dart' as manager;

import 'payload_runtime.dart';

/// 宿主包版本，由 Flutter 3.50 自动从 --build-name 或 pubspec 版本注入。
/// 不重复传入同名 dart-define；缺失构建配置时保留空值，由管理器校验。
const payloadHostAppVersion = String.fromEnvironment('FLUTTER_BUILD_NAME');

/// 创建原生资源会话；[updateUrl] 默认为宿主构建配置，可注入 loopback 测试地址。
PayloadRuntime createPayloadRuntime({String updateUrl = payloadUpdateUrl}) =>
    _NativeRuntime(updateUrl);

class _NativeRuntime extends PayloadRuntime {
  _NativeRuntime(this._updateUrl);
  final String _updateUrl;
  final _manager = manager.WebPayloadManager.getInstance();
  Future<void>? _starting;
  StreamSubscription<manager.ResourceState>? _module;
  StreamSubscription<manager.PayloadSyncState>? _sync;

  @override
  Future<void> start() => _starting ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _manager.initialize(
        updateUrl: _updateUrl,
        hostAppVersion: payloadHostAppVersion,
        webAssetBaseDir: 'assets/web_payload',
        syncOnStart: _updateUrl.isNotEmpty,
        syncOnEachModuleStart: false,
      );
      _module = _manager.getModuleStateStream('companion').listen((state) {
        if (state is manager.Data) {
          url = state.data;
          version = state.version;
          if (availableVersion == version) availableVersion = null;
          authUserAgent = _manager.getAuthUserAgent();
          failed = false;
        } else if (state is manager.Error) {
          failed = true;
        }
        notifyListeners();
      });
      void receiveSync(manager.PayloadSyncState state) {
        syncStatus = switch (state) {
          manager.SyncChecking() || manager.SyncDownloading() => 'updating',
          manager.SyncFailed() => 'failed',
          manager.SyncCompleted() || manager.SyncUpToDate() => 'ready',
          _ => 'idle',
        };
        availableVersion = _manager.availableVersion;
        if (availableVersion == version) availableVersion = null;
        notifyListeners();
      }

      _sync = _manager.payloadSyncStateStream.listen(receiveSync);
      // 初始化可能已经发出 checking/completed，读取快照避免遗漏早到事件。
      receiveSync(_manager.payloadSyncState);
    } catch (_) {
      failed = true;
      _starting = null;
      notifyListeners();
    }
  }

  @override
  Future<void> retry({bool restore = false}) async {
    failed = false;
    notifyListeners();
    if (_module == null) {
      _starting = null;
      await start();
    } else if (restore) {
      await _manager.rollbackToDefault();
    } else {
      // 保留当前快照身份；普通刷新不能隐式激活待切换的新版本。
      await _manager.ensureLocalWebServerHealthy();
    }
  }

  @override
  Future<void> activateUpdate() => _manager.activateAvailableUpdate();

  @override
  Future<void> resume() => _manager.ensureLocalWebServerHealthy();

  @override
  void dispose() {
    unawaited(_module?.cancel());
    unawaited(_sync?.cancel());
    super.dispose();
  }
}
