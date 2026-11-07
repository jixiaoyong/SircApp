import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/widgets/date_format.dart';
import '../../data/wallet_repository.dart';
import '../../domain/models/bank_card.dart';

// ==========================================
// 1. 钱包与交易历史状态 (WalletState)
// ==========================================

class WalletState {
  final double availableBalance;
  final int currentFilterIndex; // 0: Last Send, 1: Last Receive, 2: Total
  final int selectedCardIndex;
  final List<BankCard> cards;
  final List<MoneyOperateBean> transactions;
  final List<String> moneyTypes;
  final String selectedMonth;
  final List<String> monthEnglishNameList;
  final List<(String day, double percentage)> chartData;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const WalletState({
    this.availableBalance = 35.269,
    this.currentFilterIndex = 0,
    this.selectedCardIndex = 0,
    this.cards = const [],
    this.transactions = const [],
    required this.moneyTypes,
    required this.selectedMonth,
    required this.monthEnglishNameList,
    this.chartData = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  WalletState copyWith({
    double? availableBalance,
    int? currentFilterIndex,
    int? selectedCardIndex,
    List<BankCard>? cards,
    List<MoneyOperateBean>? transactions,
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
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      cards: cards ?? this.cards,
      transactions: transactions ?? this.transactions,
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

class WalletController extends Notifier<WalletState> {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  WalletState build() {
    // 监听全局语言变更，自动更新月份与分类等本地化文本
    ref.watch(localeProvider);

    final months = [
      'January'.tr,
      'February'.tr,
      'March'.tr,
      'April'.tr,
      'May'.tr,
      'June'.tr,
      'July'.tr,
      'August'.tr,
      'September'.tr,
      'October'.tr,
      'November'.tr,
      'December'.tr,
    ];

    final initialMoneyTypes = [
      'Last Send'.tr,
      'Last Receive'.tr,
      'Total'.tr,
    ];

    final defaultChart = [
      ('Mon'.tr, 0.3),
      ('Tues'.tr, 0.5),
      ('Wed'.tr, 0.1),
      ('Thur'.tr, 0.6),
      ('Fri'.tr, 0.9),
      ('Satu'.tr, 0.2),
      ('Sun'.tr, 0.8),
    ];

    // 若此前已有加载好的业务数据（如切换语言触发 rebuild），平滑保留数据，仅迁移本地化字段
    final previousState = stateOrNull;
    if (previousState != null) {
      final oldIndex =
          previousState.monthEnglishNameList.indexOf(previousState.selectedMonth);
      final newSelectedMonth =
          oldIndex >= 0 && oldIndex < months.length ? months[oldIndex] : months.first;

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
    try {
      final balance = await _repository.getAvailableBalance();
      final cards = await _repository.getBankCards();
      final transactions = await _fetchFilteredTransactions(
        filterIndex: state.currentFilterIndex,
        query: state.searchQuery,
      );
      final chart = await _repository.getMonthlyChartData(state.selectedMonth);

      state = state.copyWith(
        availableBalance: balance,
        cards: cards,
        transactions: transactions,
        chartData: chart,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// 重新获取银行卡列表
  Future<void> loadCards() async {
    final cards = await _repository.getBankCards();
    state = state.copyWith(cards: cards);
  }

  /// 切换分类过滤（0: Last Send, 1: Last Receive, 2: Total）
  Future<void> setFilterIndex(int index) async {
    if (state.currentFilterIndex == index) return;
    state = state.copyWith(currentFilterIndex: index);
    final txs = await _fetchFilteredTransactions(
      filterIndex: index,
      query: state.searchQuery,
    );
    state = state.copyWith(transactions: txs);
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
    final chart = await _repository.getMonthlyChartData(month);
    state = state.copyWith(chartData: chart);
  }

  /// 搜索过滤交易列表
  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    final txs = await _fetchFilteredTransactions(
      filterIndex: state.currentFilterIndex,
      query: query,
    );
    state = state.copyWith(transactions: txs);
  }

  /// 内部过滤解析
  Future<List<MoneyOperateBean>> _fetchFilteredTransactions({
    required int filterIndex,
    String? query,
  }) {
    final filter = switch (filterIndex) {
      0 => TransactionFilter.send,
      1 => TransactionFilter.receive,
      _ => TransactionFilter.total,
    };
    return _repository.getTransactions(filter: filter, query: query);
  }
}

final walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(
  WalletController.new,
);

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
      ownerNameError:
          ownerNameError != null ? ownerNameError() : this.ownerNameError,
      cardNumberError:
          cardNumberError != null ? cardNumberError() : this.cardNumberError,
      expireDateError:
          expireDateError != null ? expireDateError() : this.expireDateError,
      cvvError: cvvError != null ? cvvError() : this.cvvError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// ==========================================
// 4. 添加银行卡控制器 (AddCardController)
// ==========================================

class AddCardController extends Notifier<AddCardState> {
  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  AddCardState build() {
    final user = ref.watch(navigationControllerProvider);
    return AddCardState(
      ownerName: user.userName,
    );
  }

  /// 银行卡拖拽倾斜度响应
  void onBankCardPanUpdate(Offset? offset) {
    if (offset == null) {
      state = state.copyWith(cardRotateAngle: AddCardState.cardMinRotateAngle);
      return;
    }

    final dy = offset.dy;
    final dragOffsetPercent = -dy / AddCardState.cardMaxDragOffset;
    var angle = dragOffsetPercent * AddCardState.cardMaxRotateAngle +
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
    final error = trimmed.isEmpty ? 'Please type in your name'.tr : null;
    state = state.copyWith(
      ownerName: value,
      ownerNameError: () => error,
    );
  }

  /// 输入卡号
  void setCardNumber(String value) {
    final trimmed = value.trim();
    final error = trimmed.isEmpty ? 'Please enter bank card number'.tr : null;
    state = state.copyWith(
      cardNumber: value,
      cardNumberError: () => error,
    );
  }

  /// 设置卡片有效期
  void setExpireDate(DateTime value) {
    final str =
        '${DateFormat.mToMMInt(value.month)}/${DateFormat.yyyyToYYInt(value.year)}';
    final error =
        str.isNotEmpty ? null : 'Please enter an expiration date'.tr;
    state = state.copyWith(
      expireDate: value,
      expireDateString: () => str,
      expireDateError: () => error,
    );
  }

  /// 输入 CVV
  void setCvv(String value) {
    final trimmed = value.trim();
    final error = trimmed.isEmpty ? 'error' : null;
    state = state.copyWith(
      cvv: value,
      cvvError: () => error,
    );
  }

  /// 执行添加卡片
  Future<bool> addCard() async {
    if (!state.isUserInputValid || state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final newCard = BankCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: state.bankName.isNotEmpty ? state.bankName : 'Visa Classic',
        cardNumber: state.cardNumber,
        ownerName: state.ownerName,
        expirationDate: state.expireDateString ?? '00/00',
        cardType: state.cardType,
        cvv: state.cvv,
      );

      await _repository.addBankCard(newCard);
      // 同步刷新钱包卡片列表
      await ref.read(walletControllerProvider.notifier).loadCards();

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final addCardControllerProvider =
    NotifierProvider<AddCardController, AddCardState>(
  AddCardController.new,
);
