import 'package:flutter/material.dart';
import '../bean/money_operate_bean.dart';
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
import '../features/wallet/presentation/add_card_page.dart';
import '../features/wallet/presentation/history_details_page.dart';
import 'app_routes.dart';

/*
* @description: 现代路由分发管理，完全基于标准 Flutter Route
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class AppPages {
  static const INITIAL = AppRoutes.INITIAL;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.INITIAL:
        return MaterialPageRoute(
          builder: (_) => const InitialPage(),
          settings: settings,
        );
      case AppRoutes.SIGN_IN:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
          settings: settings,
        );
      case AppRoutes.SIGN_UP:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );
      case AppRoutes.FORGET_PWD:
        return MaterialPageRoute(
          builder: (_) => const ForgetPwdPage(),
          settings: settings,
        );
      case AppRoutes.SET_PWD:
        final userName = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SetPwdPage(initialUserName: userName),
          settings: settings,
        );
      case AppRoutes.MAIN:
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 0),
          settings: settings,
        );
      case '/wallet':
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 1),
          settings: settings,
        );
      case '/history':
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 2),
          settings: settings,
        );
      case '/person':
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 3),
          settings: settings,
        );
      case '/menu':
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 4),
          settings: settings,
        );
      case AppRoutes.LANGUAGES:
        return MaterialPageRoute(
          builder: (_) => const LanguagePage(),
          settings: settings,
        );
      case AppRoutes.NOTIFICATIONS:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
          settings: settings,
        );
      case AppRoutes.PASSWORD:
        return MaterialPageRoute(
          builder: (_) => const PasswordPage(),
          settings: settings,
        );
      case AppRoutes.ADD_CARD:
        return MaterialPageRoute(
          builder: (_) => const AddCardPage(),
          settings: settings,
        );
      case AppRoutes.ABOUT:
        return MaterialPageRoute(
          builder: (_) => const AboutPage(),
          settings: settings,
        );
      case AppRoutes.HISTORY_DETAILS:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final data = args['data'] as MoneyOperateBean? ??
            MoneyOperateBean(
              moneyActionName: "Payment Details",
              moneyAmount: -98.48,
              userIcon:
                  "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
            );
        final heroTag = args['heroTag'] as String? ?? 'default';
        return MaterialPageRoute(
          builder: (_) => HistoryDetailsPage(
            data: data,
            heroTag: heroTag,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: settings,
        );
    }
  }
}
