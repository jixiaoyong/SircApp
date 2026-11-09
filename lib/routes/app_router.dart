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
}) =>
    GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: storage,
      redirect: (context, state) {
        final path = state.uri.path;
        // 精确开放现有匿名认证流程；修改密码 /password 仍受保护。
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
      errorBuilder: (context, state) => const NotFoundPage(),
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
              userName = (state.extra as Map)['user_name'] as String? ??
                  (state.extra as Map)['userName'] as String?;
            }
            userName ??= state.uri.queryParameters['username'];
            return SetPwdPage(initialUserName: userName);
          },
        ),
        GoRoute(
          path: AppRoutes.MAIN,
          builder: (context, state) => const MainPage(initialIndex: 0),
        ),
        // 兼容直达主页各 Tab 的快捷路由
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const MainPage(initialIndex: 1),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const MainPage(initialIndex: 2),
        ),
        GoRoute(
          path: '/person',
          builder: (context, state) => const MainPage(initialIndex: 3),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MainPage(initialIndex: 4),
        ),
        GoRoute(
          path: AppRoutes.LANGUAGES,
          builder: (context, state) => const LanguagePage(),
        ),
        GoRoute(
          path: AppRoutes.NOTIFICATIONS,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.PASSWORD,
          builder: (context, state) => const PasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.ADD_CARD,
          builder: (context, state) => const AddCardPage(),
        ),
        GoRoute(
          path: AppRoutes.ABOUT,
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: AppRoutes.HISTORY_DETAILS,
          builder: (context, state) {
            Transaction? data;
            String heroTag = 'default';

            if (state.extra is Map<String, dynamic>) {
              final map = state.extra as Map<String, dynamic>;
              data = map['data'] as Transaction?;
              heroTag = map['heroTag'] as String? ?? 'default';
            } else if (state.extra is Transaction) {
              data = state.extra as Transaction;
            }

            data ??= Transaction(
              moneyActionName: "Payment Details",
              moneyAmount: -98.48,
              userIcon:
                  "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
            );

            return HistoryDetailsPage(
              data: data,
              heroTag: heroTag,
            );
          },
        ),
      ],
    );
