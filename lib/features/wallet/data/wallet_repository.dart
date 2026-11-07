import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/network/api_client.dart';
import 'package:sirc/mock/mock_utils.dart';
import '../domain/models/bank_card.dart';

/// 交易记录类型过滤枚举
enum TransactionFilter {
  send,
  receive,
  total,
}

/// 钱包与银行卡业务仓库接口
abstract class WalletRepository {
  /// 获取银行卡列表
  Future<List<BankCard>> getBankCards();

  /// 添加一张新的银行卡
  Future<void> addBankCard(BankCard card);

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
  Future<List<(String day, double percentage)>> getMonthlyChartData(String month);
}

/// 钱包业务仓库默认实现（基于内存与 Mock 驱动，支持 ApiClient 网络扩展）
class WalletRepositoryImpl implements WalletRepository {
  final ApiClient? _apiClient;

  WalletRepositoryImpl([this._apiClient]);

  ApiClient? get apiClient => _apiClient;

  // 初始银行卡列表（与首页默认卡片数据一致）
  final List<BankCard> _cards = [
    BankCard(
      id: '1',
      bankName: Languages.cnss,
      cardNumber: '8932 6283 3243 3232',
      ownerName: 'Juan Perez',
      expirationDate: '02/20',
      cardType: 'Visa',
    ),
    BankCard(
      id: '2',
      bankName: Languages.dxss,
      cardNumber: '8932 3223 3243 3232',
      ownerName: 'Juan Perez',
      expirationDate: '12/29',
      cardType: 'MasterCard',
    ),
    BankCard(
      id: '3',
      bankName: Languages.cid,
      cardNumber: '8932 3283 3323 3232',
      ownerName: 'Juan Perez',
      expirationDate: '11/22',
      cardType: 'Visa',
    ),
  ];

  // 初始交易记录列表
  late final List<Transaction> _transactions =
      List<Transaction>.from(MockUtils.moneyOperateList);

  final double _availableBalance = 35.269;

  @override
  Future<List<BankCard>> getBankCards() async {
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> addBankCard(BankCard card) async {
    _cards.add(card);
  }

  @override
  Future<void> deleteBankCard(String cardId) async {
    _cards.removeWhere((c) => c.id == cardId);
  }

  @override
  Future<double> getAvailableBalance() async {
    return _availableBalance;
  }

  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter filter = TransactionFilter.total,
    String? query,
  }) async {
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
    // 基础波动数据（Dart 3 原生元组）
    return [
      (Languages.mon, 0.3),
      (Languages.tues, 0.5),
      (Languages.wed, 0.1),
      (Languages.thur, 0.6),
      (Languages.fri, 0.9),
      (Languages.satu, 0.2),
      (Languages.sun, 0.8),
    ];
  }
}

/// 钱包业务仓库 Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepositoryImpl(apiClient);
});
