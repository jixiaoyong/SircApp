import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/storage/storage_service.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../../routes/app_routes.dart';

part 'settings_controller.g.dart';

/// Device preference; keep the router and authentication providers independent.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => switch (ref.watch(storageServiceProvider).themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(storageServiceProvider).setThemeMode(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

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
  final locale = parts.length > 1
      ? Locale(parts[0], parts[1])
      : Locale(parts[0]);
  ref.read(localeProvider.notifier).setLocale(locale);
}

// ============================================================================
// 2. Notifications State & Notifier
// ============================================================================

class NotificationsState {
  final int currentCategoryIndex;
  final int currentExpandIndex;

  final List<Transaction> transactions;
  final DateTime? referenceDate;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.currentCategoryIndex = 0,
    this.currentExpandIndex = 0,
    this.transactions = const [],
    this.referenceDate,
    this.isLoading = false,
    this.error,
  });

  List<String> get categories => [
    Languages.thisWeek,
    Languages.thisMonth,
    Languages.thisYear,
  ];

  List<(IconData icon, String title, List<Transaction> items)>
  get notificationGroups => [
    (Icons.transform, Languages.transfers, _itemsFor(0)),
    (Icons.monetization_on_outlined, Languages.recharge, _itemsFor(1)),
    (Icons.notes_outlined, Languages.bill, _itemsFor(2)),
    (Icons.more_horiz_outlined, Languages.others, _itemsFor(3)),
  ];

  // The existing transaction model has no category or timestamp schema. Only
  // explicit action labels are classified; unknown actions remain Other.
  int _categoryOf(Transaction item) {
    final name = (item.moneyActionName ?? '').toLowerCase();
    if (RegExp(r'transfer|money send|转账|轉帳').hasMatch(name)) return 0;
    if (RegExp(r'recharge|top.?up|充值').hasMatch(name)) return 1;
    if (RegExp(r'bill|账单|帳單').hasMatch(name)) return 2;
    return 3;
  }

  DateTime? _dateOf(Transaction item) {
    final raw = item.time?.trim() ?? '';
    // "Just now" is deliberately not converted into a fabricated timestamp.
    return DateTime.tryParse(raw.replaceAll('/', '-'))?.toLocal();
  }

  int get undatedCount =>
      transactions.where((item) => _dateOf(item) == null).length;

  List<Transaction> _itemsFor(int category) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (currentCategoryIndex) {
      0 => today.subtract(Duration(days: today.weekday - 1)),
      1 => DateTime(now.year, now.month),
      _ => DateTime(now.year),
    };
    return transactions.where((item) {
      final date = _dateOf(item);
      return _categoryOf(item) == category &&
          date != null &&
          !date.isBefore(start) &&
          !date.isAfter(now);
    }).toList();
  }

  List<Transaction> get visibleItems =>
      currentExpandIndex < 0 ? const [] : _itemsFor(currentExpandIndex);

  NotificationsState copyWith({
    int? currentCategoryIndex,
    int? currentExpandIndex,
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      currentCategoryIndex: currentCategoryIndex ?? this.currentCategoryIndex,
      currentExpandIndex: currentExpandIndex ?? this.currentExpandIndex,
      transactions: transactions ?? this.transactions,
      referenceDate: referenceDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  NotificationsState build() {
    final repository = ref.watch(walletRepositoryProvider);
    Future.microtask(() async {
      try {
        final transactions = await repository.getTransactions();
        if (!ref.mounted) return;
        state = state.copyWith(transactions: transactions, isLoading: false);
      } catch (error) {
        if (!ref.mounted) return;
        state = state.copyWith(isLoading: false, error: error.toString());
      }
    });
    return const NotificationsState(isLoading: true);
  }

  void setCategory(int category) {
    if (category < 0 || category >= state.categories.length) return;
    state = state.copyWith(currentCategoryIndex: category);
  }

  void selectNotificationCategory(int index) {
    if (index < 0 || index > 3) return;
    state = state.copyWith(currentExpandIndex: index);
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
  static List<(String image, String title, String subtitle)> get initialTips =>
      [
        (
          'assets/imgs/initial_password_transparent.webp',
          Languages.dontSharePassword,
          Languages.dontSharePasswordDetail,
        ),
        (
          'assets/imgs/initial_pin_error_transparent.webp',
          Languages.forgotPin,
          Languages.forgotPinDetail,
        ),
        (
          'assets/imgs/initial_exchange_transparent.webp',
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

    // 引导结束后直接切换入口，避免把登录页压在引导页上。
    markAsNotFirstInitial();
    context.go(getDestinationRoute());
  }
}
