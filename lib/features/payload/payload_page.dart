import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payload_native_bridge.dart';
import 'payload_runtime.dart';
import 'payload_service.dart';

/// 独立全宽 H5 分支；[runtime] 可注入测试资源会话。
class PayloadPage extends ConsumerStatefulWidget {
  /// [runtime] 留空时使用应用级原生会话。
  const PayloadPage({super.key, this.runtime});
  final PayloadRuntime? runtime;

  @override
  ConsumerState<PayloadPage> createState() => _PayloadPageState();
}

class _PayloadPageState extends ConsumerState<PayloadPage>
    with WidgetsBindingObserver {
  PayloadRuntime? get _runtime => widget.runtime ?? payloadRuntime;
  WebViewController? _web;
  PayloadNativeBridgeHandler? _nativeBridge;
  String? _session;
  bool _loading = true;
  bool _error = false;
  String? _defaultUa;
  int _generation = 0;
  bool _processRecoveryAttempted = false;
  bool _activating = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_supported) {
      _runtime?.addListener(_changed);
      unawaited(_runtime?.start());
      _changed();
    }
  }

  void _changed() {
    if (!mounted) return;
    final runtime = _runtime;
    if (runtime == null) return;
    final session = '${runtime.url}|${runtime.authUserAgent}';
    if (runtime.url != null && session != _session) {
      _session = session;
      unawaited(_load());
    }
    setState(() {});
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final isNew = _web == null;
      final web = _web ??= WebViewController();
      _nativeBridge ??= PayloadNativeBridgeHandler(webViewController: web);
      await web.setJavaScriptMode(JavaScriptMode.unrestricted);
      if (isNew) {
        try {
          await web.setBackgroundColor(Colors.transparent);
        } catch (_) {}
        try {
          await web.addJavaScriptChannel(
            'SircNativeBridge',
            onMessageReceived: (JavaScriptMessage message) {
              _handleBridgeMessage(message.message);
            },
          );
          await web.addJavaScriptChannel(
            'AppToRoute',
            onMessageReceived: (JavaScriptMessage message) {
              _handleAppToRoute(message.message);
            },
          );
        } catch (_) {
          // 测试桩环境未实现 JavaScriptChannel 时优雅降级
        }
      }
      _defaultUa ??= await web.getUserAgent();
      await web.setUserAgent(
        '${_defaultUa ?? ''} ${_runtime!.authUserAgent}'.trim(),
      );
      await web.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final target = Uri.tryParse(request.url);
            final local = Uri.parse(_runtime!.url!);
            if (target != null && isPayloadNavigation(target, local)) {
              return NavigationDecision.navigate;
            }
            // 外部系统意图协议（打电话、短信、邮件）
            final scheme = target?.scheme.toLowerCase();
            if (scheme == 'tel' || scheme == 'sms' || scheme == 'mailto') {
              try {
                await launchUrl(target!, mode: LaunchMode.externalApplication);
              } catch (_) {}
              return NavigationDecision.prevent;
            }
            // 不把含鉴权 UA 的 WebView 带到外部站点；只允许 HTTPS 外链。
            if (scheme == 'https' && request.isMainFrame) {
              try {
                await launchUrl(target!, mode: LaunchMode.externalApplication);
              } catch (_) {
                // 外部应用不可用时仍阻止携带鉴权 UA 的站外导航。
              }
            }
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) async {
            await _syncPresentation();
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.errorType ==
                    WebResourceErrorType.webContentProcessTerminated &&
                !_processRecoveryAttempted) {
              _processRecoveryAttempted = true;
              unawaited(_recoverProcess());
              return;
            }
            if (error.isForMainFrame != false && mounted) {
              setState(() {
                _loading = false;
                _error = true;
              });
            }
          },
        ),
      );
      if (generation != _generation || !mounted) return;
      await web.loadRequest(Uri.parse(_runtime!.url!));
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  void _handleBridgeMessage(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (map['action'] == 'openPage') {
        final view = map['view'] as String? ?? 'emergency';
        final title = map['title'] as String? ?? Languages.home.payloadTitle;
        if (mounted) {
          context.push(
            AppRoutes.PAYLOAD_DETAIL,
            extra: {'view': view, 'title': title},
          );
        }
      } else {
        _nativeBridge?.handleMessage(jsonStr);
      }
    } catch (_) {
      // 容错非法格式消息
    }
  }

  void _handleAppToRoute(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final path = map['path'] as String? ?? '';
      final params = (map['params'] as Map<String, dynamic>?) ?? {};
      if (path == AppRoutes.PAYLOAD_DETAIL || path == '/payload-detail') {
        final view = params['view'] as String? ?? 'emergency';
        final title = params['title'] as String? ?? Languages.home.payloadTitle;
        if (mounted) {
          context.push(
            AppRoutes.PAYLOAD_DETAIL,
            extra: {'view': view, 'title': title},
          );
        }
      }
    } catch (_) {
      // 容错非法格式消息
    }
  }

  Future<void> _syncPresentation() async {
    if (_web == null) return;
    final strings = {
      'title': Languages.home.payloadHeading,
      'description': Languages.home.payloadDescription,
      'version': Languages.home.payloadVersion,
      'lang': Localizations.localeOf(context).toLanguageTag(),
      'dark': Theme.of(context).brightness == Brightness.dark,
    };
    try {
      await _web!.runJavaScript(
        'window.sircPresentation && window.sircPresentation(${jsonEncode(strings)})',
      );
    } catch (_) {
      // 页面导航期间的脚本不可用不覆盖主文档错误状态。
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_syncPresentation());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_supported && state == AppLifecycleState.resumed) {
      unawaited(_runtime?.resume());
    }
  }

  Future<void> _recoverProcess() async {
    await _runtime?.resume();
    if (mounted && _runtime?.url != null) await _load();
  }

  Future<void> _retry({bool restore = false}) async {
    _processRecoveryAttempted = false;
    try {
      await _runtime?.retry(restore: restore);
      if (_runtime?.url != null && mounted) await _load();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _activateUpdate() async {
    if (_activating) return;
    setState(() => _activating = true);
    try {
      await _runtime?.activateUpdate();
      // Data 的不可变 URL 变化由 _changed 统一加载，不重复刷新。
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  Future<void> _back() async {
    if (await _web?.canGoBack() ?? false) await _web?.goBack();
    // 模块根不 pop 主 shell。
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runtime?.removeListener(_changed);
    _nativeBridge?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    if (_web != null) unawaited(_syncPresentation());
    final failed = _error || (_runtime?.failed ?? false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_back());
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: !_supported
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      kIsWeb
                          ? Languages.home.payloadWebUnsupported
                          : Languages.home.payloadPlatformUnsupported,
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_runtime?.availableVersion case final String available)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${Languages.home.payloadUpdateAvailable} ($available)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: _activating ? null : _activateUpdate,
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(Languages.home.payloadActivateUpdate),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          if (_web != null && !failed)
                            WebViewWidget(controller: _web!),
                          if (_loading && !failed)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 12),
                                  Text(Languages.home.payloadLoading),
                                ],
                              ),
                            ),
                          if (failed)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(Languages.home.payloadError),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      TextButton(
                                        onPressed: _retry,
                                        child: Text(Languages.home.payloadRetry),
                                      ),
                                      TextButton(
                                        onPressed: () => _retry(restore: true),
                                        child: Text(
                                          Languages.home.payloadRestore,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
