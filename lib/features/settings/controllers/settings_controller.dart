import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bean/money_operate_bean.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/storage/storage_service.dart';
import '../../../gen_a/A.dart';
import '../../../mock/mock_utils.dart';
import '../../../routes/app_routes.dart';

// ============================================================================
// 1. Language Configuration
// ============================================================================

/// 支持的语言列表（Dart 3 原生 Records）
const List<(String name, String code)> supportedLanguages = [
  ('中文', 'zh_CN'),
  ('English', 'en_US'),
];

/// 辅助切换应用语言（兼容 WidgetRef、Ref 与 ProviderContainer）
void switchAppLanguage(dynamic ref, String code) {
  final parts = code.split('_');
  final locale = parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  ref.read(localeProvider.notifier).setLocale(locale);
}

// ============================================================================
// 2. Notifications State & Notifier
// ============================================================================

class NotificationsState {
  final int currentCategoryIndex;
  final int currentExpandIndex;

  const NotificationsState({
    this.currentCategoryIndex = 0,
    this.currentExpandIndex = 0,
  });

  List<String> get categories => [
        'this week'.tr,
        'this month'.tr,
        'this year'.tr,
      ];

  List<(IconData icon, String title, List<MoneyOperateBean> items)> get notificationGroups => [
        (Icons.transform, 'Transfers'.tr, MockUtils.moneyOperateList),
        (Icons.monetization_on_outlined, 'Recharge'.tr, MockUtils.moneyOperateList),
        (Icons.notes_outlined, 'Bill'.tr, MockUtils.moneyOperateList),
        (Icons.more_horiz_outlined, 'Others'.tr, MockUtils.moneyOperateList),
      ];

  NotificationsState copyWith({
    int? currentCategoryIndex,
    int? currentExpandIndex,
  }) {
    return NotificationsState(
      currentCategoryIndex: currentCategoryIndex ?? this.currentCategoryIndex,
      currentExpandIndex: currentExpandIndex ?? this.currentExpandIndex,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    ref.watch(localeProvider);
    return const NotificationsState();
  }

  void setCategory(int category) {
    state = state.copyWith(currentCategoryIndex: category);
  }

  void setIndexExpand(int index) {
    state = state.copyWith(
      currentExpandIndex: state.currentExpandIndex == index ? -1 : index,
    );
  }

  void toggleExpand(int index) => setIndexExpand(index);
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);

// ============================================================================
// 3. Initial & Splash State & Notifier
// ============================================================================

class InitialState {
  final bool isFirstInitial;
  final bool hasCalledGoMainPage;
  final int countdownSeconds;
  final bool isAutoNavigating;

  const InitialState({
    this.isFirstInitial = true,
    this.hasCalledGoMainPage = false,
    this.countdownSeconds = 3,
    this.isAutoNavigating = false,
  });

  /// 引导页提示数据（Dart 3 原生 Records）
  static const List<(String image, String titleKey, String subtitleKey)> initialTips = [
    (
      A.assets_imgs_initial_password,
      "Don't Share Password",
      "Use strong combinations of letters,numbers and special characters to make your password.",
    ),
    (
      A.assets_imgs_initial_pin_error,
      "Forgot PIN",
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.",
    ),
    (
      A.assets_imgs_initial_exchange,
      "Manage Account",
      "Bank account make more secure keeping transaction active and changing password regularly.",
    ),
  ];

  InitialState copyWith({
    bool? isFirstInitial,
    bool? hasCalledGoMainPage,
    int? countdownSeconds,
    bool? isAutoNavigating,
  }) {
    return InitialState(
      isFirstInitial: isFirstInitial ?? this.isFirstInitial,
      hasCalledGoMainPage: hasCalledGoMainPage ?? this.hasCalledGoMainPage,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isAutoNavigating: isAutoNavigating ?? this.isAutoNavigating,
    );
  }
}

class InitialController extends Notifier<InitialState> {
  Timer? _countdownTimer;

  @override
  InitialState build() {
    final storage = ref.watch(storageServiceProvider);
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });
    return InitialState(isFirstInitial: storage.isFirstInitial);
  }

  /// 启动自动跳转倒计时（通常为 3 秒）
  void startAutoNavigateCountdown({required VoidCallback onComplete}) {
    _countdownTimer?.cancel();
    state = state.copyWith(countdownSeconds: 3, isAutoNavigating: true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds <= 1) {
        timer.cancel();
        state = state.copyWith(countdownSeconds: 0, isAutoNavigating: false);
        onComplete();
      } else {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      }
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(isAutoNavigating: false);
  }

  /// 标记已不是首次启动
  void markAsNotFirstInitial() {
    ref.read(storageServiceProvider).setFirstInitial(false);
    state = state.copyWith(isFirstInitial: false);
  }

  /// 用户是否已登录
  bool isUserLoggedIn() {
    return ref.read(storageServiceProvider).isLoginSuccess;
  }

  /// 获取下一路由
  String getDestinationRoute() {
    return isUserLoggedIn() ? AppRoutes.MAIN : AppRoutes.SIGN_IN;
  }

  /// 设置防重入状态
  void setHasCalledGoMainPage(bool called) {
    state = state.copyWith(hasCalledGoMainPage: called);
  }

  /// 执行页面跳转逻辑
  Future<void> goMainPage(BuildContext context) async {
    if (state.hasCalledGoMainPage) return;
    setHasCalledGoMainPage(true);

    bool isLogin = isUserLoggedIn();
    if (!isLogin) {
      final result = await Navigator.of(context).pushNamed(AppRoutes.SIGN_IN);
      isLogin = result == true;
    }

    if (!context.mounted) return;

    if (isLogin) {
      markAsNotFirstInitial();
      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN);
    } else {
      setHasCalledGoMainPage(false);
    }
  }
}

final initialControllerProvider =
    NotifierProvider<InitialController, InitialState>(
  InitialController.new,
);
