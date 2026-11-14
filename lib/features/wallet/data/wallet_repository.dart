import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/network/api_client.dart';
import 'package:sirc/mock/mock_data_repository.dart';

import '../domain/models/bank_card.dart';

/// 交易记录类型过滤枚举
enum TransactionFilter { send, receive, total }

/// 钱包与银行卡业务仓库接口
abstract class WalletRepository {
  Future<void> refreshLocale(Locale locale) async {}

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
  Locale _locale;
  final Map<String, Object> _memory;
  final StorageService? _storage;

  WalletRepositoryImpl([
    this._apiClient,
    MockDataRepository? mock,
    Locale locale = const Locale('zh'),
    Map<String, Object>? memory,
    this._storage,
  ]) : _mock = mock ?? MockDataRepository(),
       _locale = locale,
       _memory = memory ?? _newWalletMemory();

  ApiClient? get apiClient => _apiClient;

  Future<void>? _initializing;

  bool get _isInitialized => _memory['isInitialized'] as bool;
  List<BankCard> get _baseCards => _memory['baseCards'] as List<BankCard>;
  set _baseCards(List<BankCard> value) => _memory['baseCards'] = value;
  List<Transaction> get _baseTransactions =>
      _memory['baseTransactions'] as List<Transaction>;
  set _baseTransactions(List<Transaction> value) =>
      _memory['baseTransactions'] = value;
  Map<String, BankCard> get _cardOverrides =>
      _memory['cardOverrides'] as Map<String, BankCard>;
  Set<String> get _deletedCardIds => _memory['deletedCardIds'] as Set<String>;
  List<BankCard> get _addedCards => _memory['addedCards'] as List<BankCard>;
  double get _availableBalance => _memory['availableBalance'] as double;
  set _availableBalance(double value) => _memory['availableBalance'] = value;

  Future<void> _ensureLoaded() async {
    if (_isInitialized) return;
    try {
      await (_initializing ??= _load());
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<void> _load() async {
    final data = await _mock.wallet;
    var locale = _locale;
    var cards = await _mock.getBankCards(locale);
    var transactions = await _mock.getTransactions(locale);
    // Locale can change during fixture loading; remap before publishing data.
    while (_locale != locale) {
      locale = _locale;
      cards = await _mock.getBankCards(locale);
      transactions = await _mock.getTransactions(locale);
    }
    final storage = _storage;
    if (storage != null) {
      final addedJson = storage.addedBankCardsJson;
      if (addedJson != null && addedJson.isNotEmpty) {
        _addedCards.clear();
        for (final item in addedJson) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            _addedCards.add(BankCard.fromJson(map));
          } catch (_) {}
        }
      }
      final deletedIds = storage.deletedBankCardIds;
      if (deletedIds != null && deletedIds.isNotEmpty) {
        _deletedCardIds.addAll(deletedIds);
      }
      final overridesJson = storage.cardOverridesJson;
      if (overridesJson != null && overridesJson.isNotEmpty) {
        for (final item in overridesJson) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            final card = BankCard.fromJson(map);
            _cardOverrides[card.id] = card;
          } catch (_) {}
        }
      }
    }

    _baseCards = [for (final card in cards) _localizedCard(card)];
    _baseTransactions = transactions;
    _availableBalance = ((data['balance'] ?? 0) as num).toDouble();
    _memory['isInitialized'] = true;
  }

  @override
  Future<void> refreshLocale(Locale locale) async {
    _locale = locale;
    if (!_isInitialized) {
      await _ensureLoaded();
      if (_locale != locale) return;
    }
    final localizedCards = await _mock.getBankCards(locale);
    final localizedTransactions = await _mock.getTransactions(locale);
    if (_locale != locale) return;
    _baseCards = [for (final card in localizedCards) _localizedCard(card)];
    _baseTransactions = localizedTransactions;
  }

  BankCard _localizedCard(BankCard localized) {
    final override = _cardOverrides[localized.id];
    if (override == null) return localized;
    return override.copyWith(
      bankName: localized.bankName,
      cardNumber: override.cardNumber,
      ownerName: override.ownerName,
      expirationDate: override.expirationDate,
      cardType: override.cardType,
      cvv: override.cvv,
    );
  }

  List<BankCard> get _cards => [
    for (final base in _baseCards)
      if (!_deletedCardIds.contains(base.id)) base,
    ..._addedCards,
  ];

  List<Transaction> get _transactions => _baseTransactions;

  @override
  Future<List<BankCard>> getBankCards() async {
    await _ensureLoaded();
    return List.unmodifiable(_cards);
  }

  Future<void> _savePersistedCards() async {
    final storage = _storage;
    if (storage == null) return;
    await storage.setAddedBankCardsJson(
      _addedCards.map((c) => jsonEncode(c.toJson())).toList(),
    );
    await storage.setDeletedBankCardIds(_deletedCardIds.toList());
    await storage.setCardOverridesJson(
      _cardOverrides.values.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  @override
  Future<void> addBankCard(BankCard card) async {
    await _ensureLoaded();
    _addedCards.add(card);
    await _savePersistedCards();
  }

  @override
  Future<void> updateBankCard(BankCard card) async {
    await _ensureLoaded();
    if (!_cards.any((item) => item.id == card.id)) {
      throw StateError('Card not found');
    }
    final addedIndex = _addedCards.indexWhere((item) => item.id == card.id);
    if (addedIndex >= 0) {
      _addedCards[addedIndex] = card;
    } else {
      _cardOverrides[card.id] = card;
      final baseIndex = _baseCards.indexWhere((item) => item.id == card.id);
      if (baseIndex >= 0) {
        _baseCards[baseIndex] = _localizedCard(_baseCards[baseIndex]);
      }
    }
    await _savePersistedCards();
  }

  @override
  Future<void> deleteBankCard(String cardId) async {
    await _ensureLoaded();
    _addedCards.removeWhere((card) => card.id == cardId);
    if (_baseCards.any((card) => card.id == cardId)) {
      _deletedCardIds.add(cardId);
    }
    _cardOverrides.remove(cardId);
    await _savePersistedCards();
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

Map<String, Object> _newWalletMemory() => {
  'isInitialized': false,
  'baseCards': <BankCard>[],
  'baseTransactions': <Transaction>[],
  'cardOverrides': <String, BankCard>{},
  'deletedCardIds': <String>{},
  'addedCards': <BankCard>[],
  'availableBalance': 0.0,
};

/// 钱包业务仓库 Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final memory = ref.watch(_walletMemoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return WalletRepositoryImpl(
    apiClient,
    ref.watch(mockDataRepositoryProvider),
    ref.read(localeProvider),
    memory,
    storage,
  );
});

final _walletMemoryProvider = Provider<Map<String, Object>>(
  (ref) => _newWalletMemory(),
);
