import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/storage/storage_service.dart';
import '../../../gen_a/A.dart';
import '../../../mock/mock_utils.dart';
import '../../../routes/app_routes.dart';

part 'settings_controller.g.dart';

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
        Languages.thisWeek,
        Languages.thisMonth,
        Languages.thisYear,
      ];

  List<(IconData icon, String title, List<Transaction> items)> get notificationGroups => [
        (Icons.transform, Languages.transfers, MockUtils.moneyOperateList),
        (Icons.monetization_on_outlined, Languages.recharge, MockUtils.moneyOperateList),
        (Icons.notes_outlined, Languages.bill, MockUtils.moneyOperateList),
        (Icons.more_horiz_outlined, Languages.others, MockUtils.moneyOperateList),
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

@riverpod
class NotificationsController extends _$NotificationsController {
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

typedef NotificationsNotifier = NotificationsController;

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
  static List<(String image, String title, String subtitle)> get initialTips => [
    (
      A.assets_imgs_initial_password,
      Languages.dontSharePassword,
      Languages.dontSharePasswordDetail,
    ),
    (
      A.assets_imgs_initial_pin_error,
      Languages.forgotPin,
      Languages.forgotPinDetail,
    ),
    (
      A.assets_imgs_initial_exchange,
      Languages.manageAccount,
      Languages.manageAccountDetail,
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

@Riverpod(keepAlive: true)
class InitialController extends _$InitialController {
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
      final result = await context.push<bool>(AppRoutes.SIGN_IN);
      isLogin = result == true;
    }

    if (!context.mounted) return;

    if (isLogin) {
      markAsNotFirstInitial();
      context.go(AppRoutes.MAIN);
    } else {
      setHasCalledGoMainPage(false);
    }
  }
}
