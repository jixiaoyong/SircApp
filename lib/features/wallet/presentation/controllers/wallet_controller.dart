import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';

import '../../data/wallet_repository.dart';
import '../../domain/models/bank_card.dart';

part 'wallet_controller.g.dart';

// ==========================================
// 1. 钱包与交易历史状态 (WalletState)
// ==========================================

class WalletState {
  final double availableBalance;
  final int currentFilterIndex; // 0: Last Send, 1: Last Receive, 2: Total
  final int selectedCardIndex;
  final List<BankCard> cards;
  final List<Transaction> transactions;
  final List<Transaction> allTransactions;
  final int historyPeriod; // 0: all, 1: current week, 2: current month
  final DateTime? referenceDate;
  final List<String> moneyTypes;
  final String selectedMonth;
  final List<String> monthEnglishNameList;
  final List<(String day, double percentage)> chartData;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const WalletState({
    this.availableBalance = 0,
    this.currentFilterIndex = 0,
    this.selectedCardIndex = 0,
    this.cards = const [],
    this.transactions = const [],
    this.allTransactions = const [],
    this.historyPeriod = 0,
    this.referenceDate,
    required this.moneyTypes,
    required this.selectedMonth,
    required this.monthEnglishNameList,
    this.chartData = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Relative labels have day-level precision only; never invent a time of day.
  static DateTime? transactionDate(Transaction transaction, {DateTime? now}) {
    final text = transaction.time?.trim() ?? '';
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    switch (text.toLowerCase()) {
      case 'just now':
      case 'today':
      case '刚刚':
      case '今天':
        return today;
      case 'yesterday':
      case '昨天':
        return DateTime(today.year, today.month, today.day - 1);
    }
    // Full ISO/slash dates remain compatible. Month/day and time-only strings
    // have no reliable year/day and intentionally remain undated.
    final normalized = text.replaceAll(RegExp(r'\s*/\s*'), '-');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}(?:$|[T ])').hasMatch(normalized)) {
      return null;
    }
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    final parts = normalized
        .substring(0, 10)
        .split('-')
        .map(int.parse)
        .toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    if (date.month != parts[1] || date.day != parts[2]) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  List<Transaction> get walletTransactions => allTransactions.where((item) {
    final amount = item.moneyAmount ?? 0;
    return currentFilterIndex == 0
        ? amount < 0
        : currentFilterIndex == 1
        ? amount >= 0
        : true;
  }).toList();

  List<Transaction> get historyTransactions => allTransactions.where((item) {
    final query = searchQuery.trim().toLowerCase();
    final localizedName = item.localizedPlaceholders.moneyActionName ?? '';
    if (query.isNotEmpty &&
        !'${item.moneyActionName} $localizedName ${item.time}'
            .toLowerCase()
            .contains(query)) {
      return false;
    }
    if (historyPeriod == 0) return true;
    final date = transactionDate(item, now: referenceDate);
    if (date == null) return false;
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = historyPeriod == 1
        ? today.subtract(Duration(days: today.weekday - 1))
        : DateTime(now.year, now.month);
    final end = historyPeriod == 1
        ? start.add(const Duration(days: 7))
        : DateTime(now.year, now.month + 1);
    return !date.isBefore(start) && date.isBefore(end);
  }).toList();

  int get undatedCount => allTransactions
      .where((item) => transactionDate(item, now: referenceDate) == null)
      .length;

  List<double> weeklyAmounts(List<Transaction> items) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final result = List<double>.filled(7, 0);
    for (final item in items) {
      final date = transactionDate(item, now: referenceDate);
      if (date == null ||
          date.isBefore(start) ||
          !date.isBefore(start.add(const Duration(days: 7)))) {
        continue;
      }
      result[date.weekday - 1] += (item.moneyAmount ?? 0).abs();
    }
    return result;
  }

  WalletState copyWith({
    double? availableBalance,
    int? currentFilterIndex,
    int? selectedCardIndex,
    List<BankCard>? cards,
    List<Transaction>? transactions,
    List<Transaction>? allTransactions,
    int? historyPeriod,
    DateTime? referenceDate,
    List<String>? moneyTypes,
    String? selectedMonth,
    List<String>? monthEnglishNameList,
    List<(String, double)>? chartData,
    String? searchQuery,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return WalletState(
      availableBalance: availableBalance ?? this.availableBalance,
      currentFilterIndex: currentFilterIndex ?? this.currentFilterIndex,
      selectedCardIndex: (cards ?? this.cards).isEmpty
          ? 0
          : (selectedCardIndex ?? this.selectedCardIndex).clamp(
              0,
              (cards ?? this.cards).length - 1,
            ),
      cards: cards ?? this.cards,
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      historyPeriod: historyPeriod ?? this.historyPeriod,
      referenceDate: referenceDate ?? this.referenceDate,
      moneyTypes: moneyTypes ?? this.moneyTypes,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      monthEnglishNameList: monthEnglishNameList ?? this.monthEnglishNameList,
      chartData: chartData ?? this.chartData,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

// ==========================================
// 2. 钱包与交易历史控制器 (WalletController)
// ==========================================

@Riverpod(keepAlive: true)
class WalletController extends _$WalletController {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  bool _hasLoadedData = false;
  bool _isLoadingInitialData = false;
  Locale? _buildingLocale;
  Locale? _loadedLocale;
  Locale? _requestedLocale;
  int _localeRefreshGeneration = 0;

  @override
  WalletState build() {
    // 监听全局语言变更，自动更新月份与分类等本地化文本
    final locale = ref.watch(localeProvider);
    final repository = ref.watch(walletRepositoryProvider);
    final localeChanged = _buildingLocale != null && _buildingLocale != locale;
    _buildingLocale = locale;
    if (_loadedLocale == null && _hasLoadedData) _loadedLocale = locale;

    final months = [
      Languages.home.january,
      Languages.home.february,
      Languages.home.march,
      Languages.home.april,
      Languages.home.may,
      Languages.home.june,
      Languages.home.july,
      Languages.home.august,
      Languages.home.september,
      Languages.home.october,
      Languages.home.november,
      Languages.home.december,
    ];

    final initialMoneyTypes = [
      Languages.wallet.lastSend,
      Languages.wallet.lastReceive,
      Languages.wallet.total,
    ];

    final defaultChart = <(String, double)>[];

    // 若此前已有加载好的业务数据（如切换语言触发 rebuild），平滑保留数据，仅迁移本地化字段
    final previousState = stateOrNull;
    if (previousState != null) {
      final oldIndex = previousState.monthEnglishNameList.indexOf(
        previousState.selectedMonth,
      );
      final newSelectedMonth = oldIndex >= 0 && oldIndex < months.length
          ? months[oldIndex]
          : months.first;

      if ((_loadedLocale != locale || localeChanged) &&
          _requestedLocale != locale) {
        _requestedLocale = locale;
        Future.microtask(() => _refreshLocalizedData(locale, repository));
      }
      return previousState.copyWith(
        moneyTypes: initialMoneyTypes,
        selectedMonth: newSelectedMonth,
        monthEnglishNameList: months,
        chartData: defaultChart,
      );
    }

    final initialState = WalletState(
      moneyTypes: initialMoneyTypes,
      selectedMonth: months.first,
      monthEnglishNameList: months,
      chartData: defaultChart,
      isLoading: true,
    );

    // 异步加载真实业务数据
    Future.microtask(() => loadInitialData());

    return initialState;
  }

  /// 初始化拉取卡片、交易列表与图表
  Future<void> loadInitialData() async {
    if (_hasLoadedData || _isLoadingInitialData) return;
    _isLoadingInitialData = true;
    final loadLocale = ref.read(localeProvider);
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final balance = await _repository.getAvailableBalance();
      if (!ref.mounted) return;
      final cards = await _repository.getBankCards();
      if (!ref.mounted) return;
      final transactions = await _repository.getTransactions();
      final chart = <(String, double)>[];
      if (!ref.mounted) return;
      _hasLoadedData = true;
      _loadedLocale = loadLocale;
      _buildingLocale ??= _loadedLocale;
      if (ref.read(localeProvider) != loadLocale) {
        await _refreshLocalizedData(ref.read(localeProvider), _repository);
        return;
      }

      state = state.copyWith(
        availableBalance: balance,
        cards: cards,
        allTransactions: transactions,
        transactions: transactions
            .where(
              (item) => state.currentFilterIndex == 0
                  ? (item.moneyAmount ?? 0) < 0
                  : state.currentFilterIndex == 1
                  ? (item.moneyAmount ?? 0) >= 0
                  : true,
            )
            .toList(),
        chartData: chart,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    } finally {
      _isLoadingInitialData = false;
    }
  }

  Future<void> _refreshLocalizedData(
    Locale locale,
    WalletRepository repository,
  ) async {
    final generation = ++_localeRefreshGeneration;
    _requestedLocale = locale;
    if (!ref.mounted) return;
    try {
      await repository.refreshLocale(locale);
      if (!ref.mounted || generation != _localeRefreshGeneration) return;
      if (ref.read(localeProvider) != locale) {
        await _refreshLocalizedData(ref.read(localeProvider), repository);
        return;
      }
      final cards = await repository.getBankCards();
      final transactions = await repository.getTransactions();
      if (!ref.mounted ||
          generation != _localeRefreshGeneration ||
          ref.read(localeProvider) != locale) {
        return;
      }
      _loadedLocale = locale;
      final selectedId = state.cards.isEmpty
          ? null
          : state.cards[state.selectedCardIndex].id;
      final selected = cards.indexWhere((card) => card.id == selectedId);
      state = state.copyWith(
        cards: cards,
        selectedCardIndex: selected < 0 ? 0 : selected,
        allTransactions: transactions,
        transactions: state.searchQuery.isNotEmpty
            ? transactions
                .where((item) =>
                    '${item.moneyActionName ?? ''} ${item.time ?? ''}'
                        .toLowerCase()
                        .contains(state.searchQuery.trim().toLowerCase()))
                .toList()
            : transactions.where((item) {
                final amount = item.moneyAmount ?? 0;
                return state.currentFilterIndex == 0
                    ? amount < 0
                    : state.currentFilterIndex == 1
                    ? amount >= 0
                    : true;
              }).toList(),
      );
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(errorMessage: () => e.toString());
      }
    }
  }

  /// 重试初始化加载，清除旧错误并重新执行失败的请求。
  Future<void> retry() async {
    _hasLoadedData = false;
    await loadInitialData();
  }

  /// 重新获取银行卡列表
  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final cards = await _repository.getBankCards();
      if (!ref.mounted) return;
      final selectedId = state.cards.isEmpty
          ? null
          : state.cards[state.selectedCardIndex].id;
      final selected = cards.indexWhere((card) => card.id == selectedId);
      state = state.copyWith(
        cards: cards,
        selectedCardIndex: selected < 0 ? state.selectedCardIndex : selected,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    await _repository.deleteBankCard(id);
    await loadCards();
  }

  /// 切换分类过滤（0: Last Send, 1: Last Receive, 2: Total）
  Future<void> setFilterIndex(int index) async {
    if (state.currentFilterIndex == index) return;
    state = state.copyWith(currentFilterIndex: index);
    state = state.copyWith(transactions: state.walletTransactions);
  }

  /// 切换选中卡片
  void selectCard(int index) {
    if (state.selectedCardIndex != index) {
      state = state.copyWith(selectedCardIndex: index);
    }
  }

  /// 切换历史选中的月份
  Future<void> selectMonth(String month) async {
    if (state.selectedMonth == month) return;
    state = state.copyWith(selectedMonth: month);
    state = state.copyWith(chartData: const []);
  }

  void setHistoryPeriod(int index) {
    state = state.copyWith(historyPeriod: index.clamp(0, 2));
  }

  /// 搜索过滤交易列表
  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    state = state.copyWith(transactions: state.historyTransactions);
  }
}

// ==========================================
// 3. 添加银行卡状态 (AddCardState)
// ==========================================

class AddCardState {
  static const double cardMaxRotateAngle = math.pi / 8;
  static const double cardMinRotateAngle = math.pi / 18;
  static const double cardMaxDragOffset = 90.0;

  final double cardRotateAngle;
  final String bankName;
  final String cardType;
  final String ownerName;
  final String cardNumber;
  final DateTime? expireDate;
  final String? expireDateString;
  final String cvv;

  final String? ownerNameError;
  final String? cardNumberError;
  final String? expireDateError;
  final String? cvvError;
  final bool isSubmitting;

  const AddCardState({
    this.cardRotateAngle = cardMinRotateAngle,
    this.bankName = 'Visa Classic',
    this.cardType = 'Visa',
    this.ownerName = '',
    this.cardNumber = '',
    this.expireDate,
    this.expireDateString,
    this.cvv = '',
    this.ownerNameError,
    this.cardNumberError,
    this.expireDateError,
    this.cvvError = '',
    this.isSubmitting = false,
  });

  bool get isUserInputValid =>
      ownerNameError == null &&
      cardNumberError == null &&
      expireDateError == null &&
      cvvError == null &&
      ownerName.trim().isNotEmpty &&
      cardNumber.trim().isNotEmpty &&
      (expireDateString?.isNotEmpty ?? false) &&
      cvv.trim().isNotEmpty;

  AddCardState copyWith({
    double? cardRotateAngle,
    String? bankName,
    String? cardType,
    String? ownerName,
    String? cardNumber,
    DateTime? expireDate,
    String? Function()? expireDateString,
    String? cvv,
    String? Function()? ownerNameError,
    String? Function()? cardNumberError,
    String? Function()? expireDateError,
    String? Function()? cvvError,
    bool? isSubmitting,
  }) {
    return AddCardState(
      cardRotateAngle: cardRotateAngle ?? this.cardRotateAngle,
      bankName: bankName ?? this.bankName,
      cardType: cardType ?? this.cardType,
      ownerName: ownerName ?? this.ownerName,
      cardNumber: cardNumber ?? this.cardNumber,
      expireDate: expireDate ?? this.expireDate,
      expireDateString: expireDateString != null
          ? expireDateString()
          : this.expireDateString,
      cvv: cvv ?? this.cvv,
      ownerNameError: ownerNameError != null
          ? ownerNameError()
          : this.ownerNameError,
      cardNumberError: cardNumberError != null
          ? cardNumberError()
          : this.cardNumberError,
      expireDateError: expireDateError != null
          ? expireDateError()
          : this.expireDateError,
      cvvError: cvvError != null ? cvvError() : this.cvvError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// ==========================================
// 4. 添加银行卡控制器 (AddCardController)
// ==========================================

@riverpod
class AddCardController extends _$AddCardController {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  AddCardState build() {
    return const AddCardState();
  }

  String? _editingId;

  Future<void> startAdding() async {
    _editingId = null;
    final locale = ref.read(localeProvider);
    final profile = await ref
        .read(navigationControllerProvider.notifier)
        .loadUserProfile(locale);
    if (!ref.mounted) return;
    state = AddCardState(ownerName: profile.name);
  }

  void startEditing(BankCard? card) {
    _editingId = card?.id;
    state = AddCardState(
      ownerName: card?.ownerName ?? '',
      bankName: card?.bankName ?? 'Visa Classic',
      cardType: card?.cardType ?? 'Visa',
      cardNumber: card?.cardNumber ?? '',
      expireDateString: card?.expirationDate,
    );
    final parts = card?.expirationDate.split('/');
    if (parts != null && parts.length == 2) {
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      if (month != null && month >= 1 && month <= 12 && year != null) {
        state = state.copyWith(expireDate: DateTime(2000 + year, month));
      }
    }
  }

  /// 银行卡拖拽倾斜度响应
  void onBankCardPanUpdate(Offset? offset) {
    if (offset == null) {
      state = state.copyWith(cardRotateAngle: AddCardState.cardMinRotateAngle);
      return;
    }

    final dy = offset.dy;
    final dragOffsetPercent = -dy / AddCardState.cardMaxDragOffset;
    var angle =
        dragOffsetPercent * AddCardState.cardMaxRotateAngle +
        state.cardRotateAngle;

    angle = angle.clamp(
      -AddCardState.cardMaxRotateAngle,
      AddCardState.cardMaxRotateAngle,
    );

    state = state.copyWith(cardRotateAngle: angle);
  }

  /// 输入持卡人姓名
  void setOwnerName(String value) {
    final trimmed = value.trim();
    final error = trimmed.isEmpty
        ? Languages.wallet.pleaseTypeInYourName
        : null;
    state = state.copyWith(ownerName: value, ownerNameError: () => error);
  }

  /// 输入卡号
  void setCardNumber(String value) {
    final trimmed = value.trim();
    final error = trimmed.isEmpty
        ? Languages.wallet.pleaseEnterBankCardNumber
        : null;
    state = state.copyWith(cardNumber: value, cardNumberError: () => error);
  }

  /// 设置卡片有效期
  void setExpireDate(DateTime value) {
    final monthStr = value.month.toString().padLeft(2, '0');
    final yearStr = (value.year % 100).toString().padLeft(2, '0');
    final str = '$monthStr/$yearStr';
    final error = str.isNotEmpty
        ? null
        : Languages.wallet.pleaseEnterExpirationDate;
    state = state.copyWith(
      expireDate: value,
      expireDateString: () => str,
      expireDateError: () => error,
    );
  }

  /// 输入 CVV
  void setCvv(String value) {
    final trimmed = value.trim();
    final error = RegExp(r'^\d{4}$').hasMatch(trimmed) ? null : 'CVV: 4 digits';
    state = state.copyWith(cvv: value, cvvError: () => error);
  }

  /// 执行添加卡片
  Future<bool> addCard() async {
    if (!state.isUserInputValid || state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final newCard = BankCard(
        id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        bankName: state.bankName.isNotEmpty ? state.bankName : 'Visa Classic',
        cardNumber: state.cardNumber,
        ownerName: state.ownerName,
        expirationDate: state.expireDateString ?? '00/00',
        cardType: state.cardType,
        cvv: null,
      );

      if (_editingId == null) {
        await _repository.addBankCard(newCard);
      } else {
        await _repository.updateBankCard(newCard);
      }
      if (!ref.mounted) return false;
      // 同步刷新钱包卡片列表
      await ref.read(walletControllerProvider.notifier).loadCards();
      if (!ref.mounted) return false;

      state = state.copyWith(isSubmitting: false, cvv: '', cvvError: () => '');
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}
