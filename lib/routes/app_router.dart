import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/storage_service.dart';
import '../core/router/nav_keys.dart';
import '../features/auth/presentation/forget_pwd_page.dart';
import '../features/auth/presentation/password_page.dart';
import '../features/auth/presentation/set_pwd_page.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/home/presentation/main_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/home/presentation/menu_page.dart';
import '../features/home/presentation/person_page.dart';
import '../features/wallet/presentation/wallet_page.dart';
import '../features/wallet/presentation/history_page.dart';
import '../features/settings/presentation/about_page.dart';
import '../features/settings/presentation/initial_page.dart';
import '../features/settings/presentation/language_page.dart';
import '../features/settings/presentation/not_found_page.dart';
import '../features/settings/presentation/notifications_page.dart';
import '../features/wallet/domain/models/transaction.dart';
import '../features/wallet/presentation/add_card_page.dart';
import '../features/wallet/presentation/history_details_page.dart';
import 'app_routes.dart';

/*
* @description: 基于 GoRouter 的现代声明式路由配置
* 自动处理深链接、Web 端 URL 实时同步与页面参数解构
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
// main() 在挂载 ProviderScope 前已完成 SharedPreferences 初始化。
// 路由与认证仓储共享同一个 storage，登录/登出后主动重新校验，
// 不能只依赖启动页或某个页面中的登录检查。
final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final router = createAppRouter(storage);
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter(
  StorageService storage, {
  String initialLocation = AppRoutes.INITIAL,
}) {
  // 详情使用push保留返回栈，同时让Web地址栏反映当前详情深链。
  GoRouter.optionURLReflectsImperativeAPIs = true;
  late final GoRouter router;
  // go_router 14 的重定向不会传递 imperative push 的 extra。
  // 仅桥接旧交易快捷路由的数据，实际页面仍在来源分支 Navigator 中。
  Object? legacyTransactionExtra;
  Object? takeTransactionExtra() {
    final extra = legacyTransactionExtra;
    legacyTransactionExtra = null;
    return extra;
  }

  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: storage,
    redirect: (context, state) {
      final path = state.uri.path;
      // 精确开放现有匿名认证流程；修改密码 /menu/password 仍受保护。
      const publicPaths = {
        AppRoutes.INITIAL,
        AppRoutes.SIGN_IN,
        AppRoutes.SIGN_UP,
        AppRoutes.FORGET_PWD,
        AppRoutes.SET_PWD,
      };
      final isPublic = publicPaths.contains(path);
      if (!storage.isLoginSuccess && !isPublic) {
        return AppRoutes.SIGN_IN;
      }
      return null;
    },
    errorBuilder: (context, state) {
      // GoException 的消息可能包含完整 URL；日志仅保留路径，避免泄漏 query。
      final error = state.error?.toString().replaceAll(
        RegExp(r'[?#][^\s]*'),
        '[redacted]',
      );
      debugPrint('Router 404: uri=${state.uri.path}, error=$error');
      return const NotFoundPage();
    },
    routes: [
      GoRoute(
        path: AppRoutes.INITIAL,
        builder: (context, state) => const InitialPage(),
      ),
      GoRoute(
        path: AppRoutes.SIGN_IN,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.SIGN_UP,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.FORGET_PWD,
        builder: (context, state) => const ForgetPwdPage(),
      ),
      GoRoute(
        path: AppRoutes.SET_PWD,
        builder: (context, state) {
          String? userName;
          if (state.extra is String) {
            userName = state.extra as String;
          } else if (state.extra is Map) {
            userName =
                (state.extra as Map)['user_name'] as String? ??
                (state.extra as Map)['userName'] as String?;
          }
          userName ??= state.uri.queryParameters['username'];
          return SetPwdPage(initialUserName: userName);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainPage(
          navigationShell: shell,
          showBottomNavigation: const {
            AppRoutes.MAIN,
            AppRoutes.WALLET,
            AppRoutes.HISTORY,
            AppRoutes.PERSON,
            AppRoutes.MENU,
          }.contains(state.uri.path),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.MAIN,
                builder: (context, state) => const HomePage(),
                routes: [_transactionRoute(takeTransactionExtra)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.WALLET,
                builder: (context, state) => const WalletPage(),
                routes: [_transactionRoute(takeTransactionExtra)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.HISTORY,
                builder: (context, state) => const HistoryPage(),
                routes: [_transactionRoute(takeTransactionExtra)],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                pageBuilder: (context, state, child) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child:
                      state.uri.path ==
                          '${AppRoutes.PERSON}/${AppRoutes.TRANSACTION_SEGMENT}'
                      ? child
                      : MenuDetailLayout(
                          hasDetail: state.uri.path != AppRoutes.PERSON,
                          list: const PersonPage(),
                          paneKey: const ValueKey('person-pane'),
                          child: child,
                        ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.PERSON,
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: MediaQuery.sizeOf(context).width >= 840
                          ? const SizedBox.shrink()
                          : const PersonPage(),
                    ),
                    routes: [
                      for (final field in ['email', 'phone', 'address'])
                        _menuDetailRoute(
                          field,
                          (onBack) => PersonInformationPage(
                            field: field,
                            onBack: onBack,
                          ),
                          source: AppRoutes.PERSON,
                        ),
                      _menuDetailRoute(
                        'card',
                        (onBack) => AboutPage(onBack: onBack),
                        source: AppRoutes.PERSON,
                      ),
                      _transactionRoute(takeTransactionExtra),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                pageBuilder: (context, state, child) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: MenuDetailLayout(
                    hasDetail: state.uri.path != AppRoutes.MENU,
                    child: child,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.MENU,
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: MediaQuery.sizeOf(context).width >= 840
                          ? const SizedBox.shrink()
                          : const MenuPage(),
                    ),
                    routes: [
                      _menuDetailRoute(
                        AppRoutes.LANGUAGES_SEGMENT,
                        (onBack) => LanguagePage(onBack: onBack),
                      ),
                      _menuDetailRoute(
                        AppRoutes.NOTIFICATIONS_SEGMENT,
                        (onBack) => NotificationsPage(onBack: onBack),
                      ),
                      _menuDetailRoute(
                        AppRoutes.PASSWORD_SEGMENT,
                        (onBack) => PasswordPage(onBack: onBack),
                      ),
                      _menuDetailRoute(
                        AppRoutes.ADD_CARD_SEGMENT,
                        (onBack) => AddCardPage(onBack: onBack),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.ABOUT,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.HISTORY_DETAILS,
        redirect: (context, state) {
          legacyTransactionExtra = state.extra;
          final current = router.routerDelegate.currentConfiguration.uri.path;
          final branch = current.startsWith(AppRoutes.WALLET)
              ? AppRoutes.WALLET
              : current.startsWith(AppRoutes.PERSON)
              ? AppRoutes.PERSON
              : current.startsWith(AppRoutes.MAIN)
              ? AppRoutes.MAIN
              : AppRoutes.HISTORY;
          return '$branch/${AppRoutes.TRANSACTION_SEGMENT}';
        },
      ),
    ],
  );
  return router;
}

GoRoute _menuDetailRoute(
  String path,
  Widget Function(VoidCallback? onBack) buildDetail, {
  String source = AppRoutes.MENU,
}) => GoRoute(
  path: path,
  pageBuilder: (context, state) {
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    final detail = Builder(
      builder: (detailContext) => buildDetail(
        isWide
            ? () {
                final navigator = Navigator.of(detailContext);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  detailContext.go(source);
                }
              }
            : null,
      ),
    );
    return isWide
        ? _MenuNoTransitionPage(key: state.pageKey, child: detail)
        : _MenuMaterialPage(key: state.pageKey, child: detail);
  },
);

// 两种页面共享可更新的 Route，跨断点只切换展示方式，不销毁输入状态。
class _MenuMaterialPage extends MaterialPage<void> {
  const _MenuMaterialPage({required super.key, required super.child});

  @override
  bool canUpdate(Page<dynamic> other) =>
      (other is _MenuMaterialPage || other is _MenuNoTransitionPage) &&
      key == other.key;

  @override
  Route<void> createRoute(BuildContext context) => _menuPageRoute(this);
}

class _MenuNoTransitionPage extends NoTransitionPage<void> {
  const _MenuNoTransitionPage({required super.key, required super.child});

  @override
  bool canUpdate(Page<dynamic> other) =>
      (other is _MenuMaterialPage || other is _MenuNoTransitionPage) &&
      key == other.key;

  @override
  Route<void> createRoute(BuildContext context) => _menuPageRoute(this);
}

Route<void> _menuPageRoute(Page<void> page) {
  late final MaterialPageRoute<void> route;
  route = _MenuDetailPageRoute(
    settings: page,
    builder: (context) {
      final settings = route.settings;
      return settings is MaterialPage<void>
          ? settings.child
          : (settings as NoTransitionPage<void>).child;
    },
  );
  return route;
}

class _MenuDetailPageRoute extends MaterialPageRoute<void> {
  _MenuDetailPageRoute({required super.settings, required super.builder});

  @override
  Duration get transitionDuration => settings is NoTransitionPage<void>
      ? Duration.zero
      : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => settings is NoTransitionPage<void>
      ? child
      : super.buildTransitions(context, animation, secondaryAnimation, child);
}

// 详情与来源列表共用分支 Navigator，Hero 不跨根/分支边界。
GoRoute _transactionRoute(Object? Function() takeLegacyExtra) => GoRoute(
  path: AppRoutes.TRANSACTION_SEGMENT,
  pageBuilder: (context, state) {
    final extra = state.extra ?? takeLegacyExtra();
    return MaterialPage(
      key: state.pageKey,
      child: _TransactionDetail(extra: extra),
    );
  },
);

class _TransactionDetail extends StatefulWidget {
  const _TransactionDetail({required this.extra});
  final Object? extra;

  @override
  State<_TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<_TransactionDetail> {
  late final Object? extra = widget.extra;

  @override
  Widget build(BuildContext context) {
    Transaction? data;
    String heroTag = 'default';

    final routeExtra = extra;
    if (routeExtra is Map<String, dynamic>) {
      final map = routeExtra;
      data = map['data'] as Transaction?;
      heroTag = map['heroTag'] as String? ?? 'default';
    } else if (routeExtra is Transaction) {
      data = routeExtra;
    }

    data ??= Transaction(
      moneyActionName: "Payment Details",
      moneyAmount: -98.48,
      userIcon: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
    );

    return HistoryDetailsPage(data: data, heroTag: heroTag);
  }
}
