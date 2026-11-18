import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payload_runtime.dart';
import 'payload_service.dart';

/// 独立全屏 H5 详情子页面（脱离底部导航栏，拥有完整视口）。
class PayloadDetailPage extends ConsumerStatefulWidget {
  const PayloadDetailPage({
    super.key,
    required this.view,
    required this.title,
    this.runtime,
  });

  final String view;
  final String title;
  final PayloadRuntime? runtime;

  @override
  ConsumerState<PayloadDetailPage> createState() => _PayloadDetailPageState();
}

class _PayloadDetailPageState extends ConsumerState<PayloadDetailPage>
    with WidgetsBindingObserver {
  PayloadRuntime? get _runtime => widget.runtime ?? payloadRuntime;
  WebViewController? _web;
  String? _session;
  bool _loading = true;
  bool _error = false;
  String? _defaultUa;
  int _generation = 0;
  bool _processRecoveryAttempted = false;

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

  String _buildTargetUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final query = Map<String, String>.from(uri.queryParameters);
    query['mode'] = 'standalone';
    query['view'] = widget.view;
    return uri.replace(queryParameters: query).toString();
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
      await web.setJavaScriptMode(JavaScriptMode.unrestricted);
      if (isNew) {
        try {
          await web.setBackgroundColor(Colors.transparent);
        } catch (_) {}
        try {
          await web.addJavaScriptChannel(
            'AppClose',
            onMessageReceived: (_) => _closePage(),
          );
          await web.addJavaScriptChannel(
            'SircNativeBridge',
            onMessageReceived: (JavaScriptMessage message) {
              _handleBridgeMessage(message.message);
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
            if (target?.scheme == 'https' && request.isMainFrame) {
              try {
                await launchUrl(target!, mode: LaunchMode.externalApplication);
              } catch (_) {}
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
      final targetUrl = _buildTargetUrl(_runtime!.url!);
      await web.loadRequest(Uri.parse(targetUrl));
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _syncPresentation() async {
    if (_web == null) return;
    final strings = {
      'title': widget.title,
      'description': Languages.home.payloadDescription,
      'version': Languages.home.payloadVersion,
      'lang': Localizations.localeOf(context).toLanguageTag(),
      'dark': Theme.of(context).brightness == Brightness.dark,
    };
    try {
      await _web!.runJavaScript(
        'window.sircPresentation && window.sircPresentation(${jsonEncode(strings)})',
      );
    } catch (_) {}
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

  void _closePage() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleBridgeMessage(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (map['action'] == 'close') {
        _closePage();
      }
    } catch (_) {
      // 容错非法格式消息
    }
  }

  Future<void> _handleBack() async {
    try {
      final res = await _web?.runJavaScriptReturningResult(
        'window.__tryGoBack ? window.__tryGoBack() : false',
      );
      final handled = res == true || res == 'true' || res == 1;
      if (!handled) {
        _closePage();
      }
    } catch (_) {
      _closePage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runtime?.removeListener(_changed);
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
        if (!didPop) unawaited(_handleBack());
      },
      child: Scaffold(
        body: SafeArea(
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
              : Stack(
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
                            TextButton(
                              onPressed: () => unawaited(_load()),
                              child: Text(Languages.home.payloadRetry),
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
