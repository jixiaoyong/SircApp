import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/layout/adaptive_detail_layout.dart';

import '../core/layout/app_layout.dart';
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
import '../features/settings/presentation/appearance_page.dart';
import '../features/settings/presentation/not_found_page.dart';
import '../features/settings/presentation/notifications_page.dart';
import '../features/wallet/presentation/add_card_page.dart';
import '../features/wallet/presentation/card_management_page.dart';
import '../features/wallet/presentation/transaction_detail_page.dart';
import 'adaptive_detail_page.dart';
import 'app_routes.dart';
import '../features/home/presentation/article_detail_page.dart';

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
  // 同一来源子树在窄屏根 Route 与宽屏窗格间移动，保留滚动及页面状态。
  final personKey = GlobalKey(debugLabel: 'adaptive-person');
  Widget person() => KeyedSubtree(key: personKey, child: const PersonPage());
  late final GoRouter router;
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
      return NotFoundPage(path: state.uri.path);
    },
    routes: [
      GoRoute(
        path: AppRoutes.INITIAL,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const InitialPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.SIGN_IN,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SignInPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.SIGN_UP,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SignUpPage(),
        ),
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
          _sourceBranch(AppRoutes.MAIN, const HomePage()),
          _sourceBranch(AppRoutes.WALLET, const WalletPage()),
          _sourceBranch(AppRoutes.HISTORY, const HistoryPage()),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                pageBuilder: (context, state, child) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: AdaptiveDetailLayout(
                    hasDetail: state.uri.path != AppRoutes.PERSON,
                    primary: AppLayout.isWideWindow(context)
                        ? person()
                        : const SizedBox.shrink(),
                    primaryPaneKey: const ValueKey('person-pane'),
                    detail: child,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.PERSON,
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: AppLayout.isWideWindow(context)
                          ? const SizedBox.shrink()
                          : person(),
                    ),
                    routes: [
                      for (final field in ['email', 'phone', 'address'])
                        _adaptiveDetailRoute(
                          field,
                          (onBack) => PersonInformationPage(
                            field: field,
                            onBack: onBack,
                          ),
                          source: AppRoutes.PERSON,
                        ),
                      _adaptiveDetailRoute(
                        'card',
                        (onBack) => PersonCardsPage(onBack: onBack),
                        source: AppRoutes.PERSON,
                      ),
                      ..._cardEditorRoutes(AppRoutes.PERSON),
                      _transactionRoute(),
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
                  child: AdaptiveDetailLayout(
                    hasDetail: state.uri.path != AppRoutes.MENU,
                    primary: const MenuPage(listOnly: true),
                    primaryPaneKey: const ValueKey('menu-pane'),
                    detail: child,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.MENU,
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: AppLayout.isWideWindow(context)
                          ? const SizedBox.shrink()
                          : const MenuPage(),
                    ),
                    routes: [
                      _adaptiveDetailRoute(
                        AppRoutes.LANGUAGES_SEGMENT,
                        (onBack) => LanguagePage(onBack: onBack),
                      ),
                      _adaptiveDetailRoute(
                        AppRoutes.APPEARANCE_SEGMENT,
                        (onBack) => AppearancePage(onBack: onBack),
                      ),
                      _adaptiveDetailRoute(
                        AppRoutes.NOTIFICATIONS_SEGMENT,
                        (onBack) => NotificationsPage(onBack: onBack),
                      ),
                      _adaptiveDetailRoute(
                        AppRoutes.PASSWORD_SEGMENT,
                        (onBack) => PasswordPage(onBack: onBack),
                      ),
                      GoRoute(
                        path: AppRoutes.ADD_CARD_SEGMENT,
                        redirect: (context, state) => '/wallet/add-card',
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
    ],
  );
  return router;
}

StatefulShellBranch _sourceBranch(String source, Widget list) =>
    StatefulShellBranch(
      routes: [
        ShellRoute(
          pageBuilder: (context, state, child) => NoTransitionPage<void>(
            key: state.pageKey,
            child: AdaptiveDetailLayout(
              hasDetail: state.uri.path != source,
              primary: list,
              primaryPaneKey: ValueKey('$source-pane'),
              keepPrimaryMounted: true,
              detail: child,
            ),
          ),
          routes: [
            GoRoute(
              path: source,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const SizedBox.shrink(),
              ),
              routes: [
                if (source == AppRoutes.WALLET) ...[
                  _adaptiveDetailRoute(
                    'cards',
                    (onBack) => CardManagementPage(onBack: onBack),
                    source: source,
                  ),
                  ..._cardEditorRoutes(source),
                ],
                _transactionRoute(),
                if (source == AppRoutes.MAIN)
                  GoRoute(
                    path: 'article/:id',
                    pageBuilder: (context, state) {
                      final child = ArticleDetailPage(
                        id: state.pathParameters['id']!,
                      );
                      return createAdaptiveDetailPage(
                        context: context,
                        key: state.pageKey,
                        child: child,
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ],
    );

// 管理和编辑保持在来源分支内；直接深链也能返回该来源的管理页。
List<GoRoute> _cardEditorRoutes(String source) => [
  for (final path in ['add-card', 'edit-card/:id'])
    GoRoute(
      path: path,
      pageBuilder: (context, routeState) {
        final editingId = routeState.pathParameters['id'];
        final managementPath = source == AppRoutes.PERSON
            ? AppRoutes.PERSON_CARD
            : '$source/cards';
        final returnsToManagement =
            source == AppRoutes.PERSON ||
            editingId != null ||
            routeState.uri.queryParameters['from'] == 'cards';
        final backTo = returnsToManagement ? managementPath : source;
        void back() {
          if (returnsToManagement) {
            context.replace(backTo);
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go(backTo);
          }
        }

        final detail = PopScope(
          canPop: !returnsToManagement,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) back();
          },
          child: CardEditorPage(
            key: ValueKey(editingId ?? 'new-card'),
            editingId: editingId,
            onBack: back,
          ),
        );
        return createAdaptiveDetailPage(
          context: context,
          key: routeState.pageKey,
          child: detail,
        );
      },
    ),
];

/// 注册详情路由，并为宽屏详情提供返回来源的回调。
///
/// 宽屏优先弹出详情所在的内层 Navigator；无法弹出时跳转到 [source]。
/// 窄屏传入 null，由详情页沿用默认返回逻辑；页面动画交给 [createAdaptiveDetailPage]。
GoRoute _adaptiveDetailRoute(
  String path,
  Widget Function(VoidCallback? onBack) buildDetail, {
  String source = AppRoutes.MENU,
}) => GoRoute(
  path: path,
  pageBuilder: (context, state) {
    final isWide = AppLayout.isWideWindow(context);
    // 等详情挂入路由后再取 context，确保找到内层 Navigator，而非外层 Shell。
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
    return createAdaptiveDetailPage(
      context: context,
      key: state.pageKey,
      child: detail,
    );
  },
);

// 详情与来源列表共用分支 Navigator，Hero 不跨根/分支边界。
GoRoute _transactionRoute() => GoRoute(
  path: AppRoutes.TRANSACTION_SEGMENT,
  pageBuilder: (context, state) {
    final child = TransactionDetailPage.fromExtra(extra: state.extra);
    return createAdaptiveDetailPage(
      context: context,
      key: state.pageKey,
      child: child,
    );
  },
);
