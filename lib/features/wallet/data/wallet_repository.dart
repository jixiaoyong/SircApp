import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/network/api_client.dart';
import 'package:sirc/mock/mock_data_repository.dart';

import '../domain/models/bank_card.dart';

/// 交易记录类型过滤枚举
enum TransactionFilter { send, receive, total }

/// 钱包与银行卡业务仓库接口
abstract class WalletRepository {
  /// 获取银行卡列表
  Future<List<BankCard>> getBankCards();

  /// 添加一张新的银行卡
  Future<void> addBankCard(BankCard card);

  /// 按稳定 ID 更新卡片，不影响交易。
  Future<void> updateBankCard(BankCard card);

  /// 删除指定银行卡
  Future<void> deleteBankCard(String cardId);

  /// 获取当前可用余额
  Future<double> getAvailableBalance();

  /// 获取交易明细列表（支持分类过滤与模糊搜索）
  Future<List<Transaction>> getTransactions({
    TransactionFilter filter = TransactionFilter.total,
    String? query,
  });

  /// 获取指定月份的收支波动图表数据 (Dart 3 原生元组)
  Future<List<(String day, double percentage)>> getMonthlyChartData(
    String month,
  );
}

/// 钱包业务仓库默认实现（基于内存与 Mock 驱动，支持 ApiClient 网络扩展）
class WalletRepositoryImpl implements WalletRepository {
  final ApiClient? _apiClient;
  final MockDataRepository _mock;
  final Locale _locale;

  WalletRepositoryImpl([
    this._apiClient,
    MockDataRepository? mock,
    Locale locale = const Locale('zh'),
  ]) : _mock = mock ?? MockDataRepository(),
       _locale = locale;

  ApiClient? get apiClient => _apiClient;

  final List<BankCard> _cards = [];
  final List<Transaction> _transactions = [];
  double _availableBalance = 0;
  Future<void>? _initializing;

  Future<void> _ensureLoaded() => _initializing ??= _load();
  Future<void> _load() async {
    final data = await _mock.wallet;
    _cards.addAll(await _mock.getBankCards(_locale));
    _transactions.addAll(await _mock.getTransactions(_locale));
    _availableBalance = ((data['balance'] ?? 0) as num).toDouble();
  }

  @override
  Future<List<BankCard>> getBankCards() async {
    await _ensureLoaded();
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> addBankCard(BankCard card) async {
    await _ensureLoaded();
    _cards.add(card);
  }

  @override
  Future<void> updateBankCard(BankCard card) async {
    await _ensureLoaded();
    final index = _cards.indexWhere((item) => item.id == card.id);
    if (index < 0) throw StateError('Card not found');
    _cards[index] = card;
  }

  @override
  Future<void> deleteBankCard(String cardId) async {
    await _ensureLoaded();
    _cards.removeWhere((c) => c.id == cardId);
  }

  @override
  Future<double> getAvailableBalance() async {
    await _ensureLoaded();
    return _availableBalance;
  }

  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter filter = TransactionFilter.total,
    String? query,
  }) async {
    await _ensureLoaded();
    var result = _transactions.where((item) {
      final amount = item.moneyAmount ?? 0.0;
      return switch (filter) {
        TransactionFilter.send => amount < 0,
        TransactionFilter.receive => amount >= 0,
        TransactionFilter.total => true,
      };
    });

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((item) {
        final name = (item.moneyActionName ?? '').toLowerCase();
        final time = (item.time ?? '').toLowerCase();
        return name.contains(q) || time.contains(q);
      });
    }

    return result.toList();
  }

  @override
  Future<List<(String, double)>> getMonthlyChartData(String month) async {
    await _ensureLoaded();
    final raw = ((await _mock.wallet)['chart'] as List).cast<List>();
    return raw
        .map((row) => (row[0] as String, (row[1] as num).toDouble()))
        .toList();
  }
}

/// 钱包业务仓库 Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final locale = ref.watch(localeProvider);
  return WalletRepositoryImpl(
    apiClient,
    ref.watch(mockDataRepositoryProvider),
    locale,
  );
});
