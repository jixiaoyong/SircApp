import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 网页 URL 实时同步监听器
/// 在路由 push / pop / replace 时，实时同步浏览器地址栏 URL
class WebUrlSyncObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _syncUrl(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _syncUrl(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _syncUrl(newRoute);
    }
  }

  void _syncUrl(Route<dynamic> route) {
    if (!kIsWeb) return;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      final path = name.startsWith('/') ? name : '/$name';
      SystemNavigator.routeInformationUpdated(uri: Uri.parse(path));
    }
  }
}
