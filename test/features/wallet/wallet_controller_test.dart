import 'dart:ui';

import 'package:sirc/features/wallet/domain/services/transaction_service.dart';

import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/mock/mock_data_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

class _RetryWalletRepository extends WalletRepositoryImpl {
  _RetryWalletRepository({required this.onBalance});
  final Future<double> Function() onBalance;

  @override
  Future<double> getAvailableBalance() => onBalance();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLocale.setLocale(const Locale('en', 'US'));
  });

  group('Wallet date aggregation', () {
    final now = DateTime(2026, 11, 10, 23, 59);
    WalletState state(List<Transaction> items) => WalletState(
      moneyTypes: const [],
      selectedMonth: '',
      monthEnglishNameList: const [],
      referenceDate: now,
      allTransactions: items,
    );

    test('only explicit ISO dates and zoned instants are accepted', () {
      for (final raw in [
        'Just now',
        'Today',
        '刚刚',
        '今天',
        'Yesterday',
        '昨天',
        '11/10',
        '10:30',
        'unknown',
        '2026-02-30',
        '',
        '2026 / 11 / 09',
        '2026-11-09T10:30:00',
      ]) {
        expect(WalletState.transactionDate(Transaction(time: raw)), isNull);
      }
      expect(
        WalletState.transactionDate(Transaction(time: '2026-11-09')),
        DateTime(2026, 11, 9),
      );
      expect(
        WalletState.transactionDate(Transaction(time: '2026-11-09T10:30:00Z')),
        DateTime.utc(2026, 11, 9, 10, 30).toLocal(),
      );
    });

    test(
      'seven days, week boundaries, filters and zero preserve genuine volume',
      () {
        final data = state([
          for (var day = 9; day <= 15; day++)
            Transaction(
              time: '2026-11-${day.toString().padLeft(2, '0')}',
              moneyAmount: -day.toDouble(),
            ),
          Transaction(time: '2026-11-10', moneyAmount: 100),
          Transaction(time: '2026-11-08', moneyAmount: 999),
          Transaction(time: '2026-11-16', moneyAmount: 999),
          Transaction(time: 'unknown', moneyAmount: 999),
        ]);
        expect(data.weeklyAmounts(data.allTransactions), [
          9,
          110,
          11,
          12,
          13,
          14,
          15,
        ]);
        expect(
          data.weeklyAmounts(
            data.copyWith(currentFilterIndex: 1).walletTransactions,
          ),
          [0, 100, 0, 0, 0, 0, 0],
        );
        expect(data.weeklyAmounts([]), List.filled(7, 0));
        expect(data.undatedCount, 1);
      },
    );

    test('card index clamps after deletion and handles empty cards', () {
      const card = BankCard(
        id: 'a',
        bankName: 'A',
        cardNumber: '1111',
        ownerName: 'A',
        expirationDate: '12/29',
      );
      final empty = state([]);
      expect(empty.copyWith(selectedCardIndex: 9).selectedCardIndex, 0);
      final three = empty.copyWith(
        cards: [card, card, card],
        selectedCardIndex: 2,
      );
      expect(three.copyWith(cards: [card]).selectedCardIndex, 0);
      expect(three.copyWith(cards: []).selectedCardIndex, 0);
      expect(three.copyWith(selectedCardIndex: -2).selectedCardIndex, 0);
    });
  });

  group('History calendar buckets', () {
    test('week includes future Sunday and sums absolute amounts', () {
      final chart = TransactionStatistics.historyBuckets(
        [
          Transaction(time: '2026-11-09', moneyAmount: -20),
          Transaction(time: '2026-11-09', moneyAmount: 10),
          Transaction(time: '2026-11-15', moneyAmount: -70),
        ],
        period: 1,
        referenceDate: DateTime(2026, 11, 10),
      );
      expect(chart.values, [30, 0, 0, 0, 0, 0, 70]);
      expect(chart.dates.first, DateTime(2026, 11, 9));
      expect(chart.dates.last, DateTime(2026, 11, 15));
    });

    for (final (year, month, days) in [
      (2026, 2, 28),
      (2028, 2, 29),
      (2026, 11, 30),
      (2026, 12, 31),
    ]) {
      test('month $year-$month preserves all $days days', () {
        final chart = TransactionStatistics.historyBuckets(
          [
            Transaction(
              time: '$year-${month.toString().padLeft(2, '0')}-$days',
              moneyAmount: -50,
            ),
          ],
          period: 2,
          referenceDate: DateTime(year, month, 1),
        );
        expect(chart.values, hasLength(days));
        expect(chart.values.last, 50);
        expect(chart.values.take(days - 1), everyElement(0));
      });
    }

    test(
      'all fills from earliest year January through latest month',
      () {
        final chart = TransactionStatistics.historyBuckets(
          [
            Transaction(time: '2027-02-02', moneyAmount: -30),
            Transaction(time: '2026-11-01', moneyAmount: 10),
            Transaction(time: 'unknown', moneyAmount: 999),
          ],
          period: 0,
          referenceDate: DateTime(2026),
        );
        expect(chart.values, [...List<double>.filled(10, 0), 10, 0, 0, 30]);
        expect(chart.dates, [
          for (var month = 1; month <= 14; month++) DateTime(2026, month),
        ]);
        final single = TransactionStatistics.historyBuckets(
          [Transaction(time: '2026-11-01', moneyAmount: -10)],
          period: 0,
          referenceDate: DateTime(2030),
        );
        expect(single.values, [...List<double>.filled(10, 0), 10]);
        expect(single.dates, [
          for (var month = 1; month <= 11; month++) DateTime(2026, month),
        ]);
        final crossYear = TransactionStatistics.historyBuckets(
          [
            Transaction(time: '2025-12-01', moneyAmount: -10),
            Transaction(time: '2026-02-01', moneyAmount: 20),
          ],
          period: 0,
          referenceDate: DateTime(2030),
        );
        expect(crossYear.values, [...List<double>.filled(11, 0), 10, 0, 20]);
        expect(crossYear.dates, [
          for (var month = 1; month <= 14; month++) DateTime(2025, month),
        ]);
        expect(
          TransactionStatistics.historyBuckets(
            [Transaction(time: 'unknown', moneyAmount: 10)],
            period: 0,
            referenceDate: DateTime(2026),
          ).values,
          isEmpty,
        );
      },
    );
  });

  group('WalletRepository Tests', () {
    late WalletRepository repository;

    setUp(() {
      repository = WalletRepositoryImpl();
    });

    test(
      'transaction refresh follows mock days and weeks without duplicates',
      () async {
        var now = DateTime(2026, 11, 16, 18);
        final repository = WalletRepositoryImpl(
          null,
          MockDataRepository(clock: () => now),
          const Locale('en'),
        );
        Future<List<Transaction>> weekly() async =>
            (await repository.getTransactions())
                .where((item) => item.id?.startsWith('mock-week-') ?? false)
                .toList();

        final monday = await weekly();
        expect(monday, hasLength(1));
        expect(
          (await weekly()).map((item) => item.id),
          monday.map((item) => item.id),
        );
        now = DateTime(2026, 11, 17, 18);
        final tuesday = await weekly();
        expect(tuesday, hasLength(2));
        expect(tuesday.last.id, monday.single.id);
        expect(tuesday.first.moneyActionName, 'Weekly Market');
        now = DateTime(2026, 11, 22, 18);
        expect(await weekly(), hasLength(7));
        now = DateTime(2026, 11, 23, 18);
        final nextWeek = await weekly();
        expect(nextWeek, hasLength(1));
        expect(nextWeek.single.id, isNot(monday.single.id));
        await repository.refreshLocale(const Locale('zh'));
        expect((await weekly()).single.moneyActionName, '本周咖啡');
        expect(
          await repository.getTransactions(
            filter: TransactionFilter.receive,
            query: '本周咖啡',
          ),
          isEmpty,
        );
      },
    );

    test(
      'Initial bank cards should not be empty and contain default cards',
      () async {
        final cards = await repository.getBankCards();
        expect(cards.length, greaterThanOrEqualTo(3));
        expect(cards.any((c) => c.id == 'card-test-001'), isTrue);
        expect(cards.any((c) => c.bankName == '北辰信用社'), isTrue);
      },
    );

    test(
      'JSON fixtures load and map business fields for explicit Locale',
      () async {
        final mock = MockDataRepository(
          clock: () => DateTime(2026, 11, 16, 18),
        );
        final english = WalletRepositoryImpl(
          null,
          mock,
          const Locale('en', 'US'),
        );
        final chinese = WalletRepositoryImpl(
          null,
          mock,
          const Locale('zh', 'CN'),
        );
        expect(await english.getAvailableBalance(), 39615.16);
        expect(
          (await english.getBankCards()).first.bankName,
          'Northstar Credit Union',
        );
        expect((await chinese.getBankCards()).first.bankName, '北辰信用社');
        expect(
          (await english.getTransactions()).last.moneyActionName,
          'Cornerstone Coffee',
        );
        expect((await chinese.getTransactions()).last.moneyActionName, '基石咖啡');
        final englishItems = await english.getTransactions();
        final chineseItems = await chinese.getTransactions();
        expect(englishItems.length, 31);
        for (final items in [
          await mock.getTransactions(const Locale('en')),
          englishItems,
          chineseItems,
          await english.getTransactions(filter: TransactionFilter.send),
          await english.getTransactions(query: 'Weekly'),
        ]) {
          for (var i = 1; i < items.length; i++) {
            expect(
              DateTime.parse(items[i - 1].time!)
                  .isBefore(DateTime.parse(items[i].time!)),
              isFalse,
              reason: '交易应按实际时间倒序返回',
            );
          }
        }
        expect(
          chineseItems.map((item) => item.time).toList(),
          englishItems.map((item) => item.time).toList(),
        );
        final zonedIso = RegExp(
          r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|[+-]\d{2}:\d{2})$',
        );
        for (final item in englishItems) {
          expect(zonedIso.hasMatch(item.time!), isTrue, reason: item.id);
          expect(
            WalletState.transactionDate(item),
            DateTime.parse(item.time!).toLocal(),
          );
          expect(Transaction.fromJson(item.toJson()).time, item.time);
        }
        expect(
          DateTime.parse(englishItems.last.time!),
          DateTime.utc(2026, 11, 1, 16, 42),
        );
      },
    );

    test('addBankCard should successfully add a card to repository', () async {
      final initialCount = (await repository.getBankCards()).length;
      const newCard = BankCard(
        id: 'test_card_1',
        bankName: 'Test Bank',
        cardNumber: '1111 2222 3333 4444',
        ownerName: 'Alice',
        expirationDate: '08/28',
        cardType: 'Visa',
      );

      await repository.addBankCard(newCard);
      final cards = await repository.getBankCards();

      expect(cards.length, equals(initialCount + 1));
      expect(cards.any((c) => c.id == 'test_card_1'), isTrue);
    });

    test('deleteBankCard should remove the card by id', () async {
      const newCard = BankCard(
        id: 'to_delete_id',
        bankName: 'Delete Bank',
        cardNumber: '9999 8888 7777 6666',
        ownerName: 'Bob',
        expirationDate: '05/26',
      );
      await repository.addBankCard(newCard);
      expect(
        (await repository.getBankCards()).any((c) => c.id == 'to_delete_id'),
        isTrue,
      );

      await repository.deleteBankCard('to_delete_id');
      expect(
        (await repository.getBankCards()).any((c) => c.id == 'to_delete_id'),
        isFalse,
      );
    });

    test(
      'getTransactions with TransactionFilter.send filters negative amounts',
      () async {
        final sendTxs = await repository.getTransactions(
          filter: TransactionFilter.send,
        );
        expect(sendTxs.every((item) => (item.moneyAmount ?? 0) < 0), isTrue);
      },
    );

    test(
      'getTransactions with TransactionFilter.receive filters positive amounts',
      () async {
        final receiveTxs = await repository.getTransactions(
          filter: TransactionFilter.receive,
        );
        expect(
          receiveTxs.every((item) => (item.moneyAmount ?? 0) >= 0),
          isTrue,
        );
      },
    );

    test(
      'getTransactions with TransactionFilter.total returns all items',
      () async {
        final totalTxs = await repository.getTransactions(
          filter: TransactionFilter.total,
        );
        final sendTxs = await repository.getTransactions(
          filter: TransactionFilter.send,
        );
        final receiveTxs = await repository.getTransactions(
          filter: TransactionFilter.receive,
        );

        expect(totalTxs.length, equals(sendTxs.length + receiveTxs.length));
      },
    );

    test(
      'getTransactions with search query filters action name or time',
      () async {
        final txs = await repository.getTransactions(query: 'Something');
        expect(
          txs.every(
            (t) =>
                (t.moneyActionName ?? '').toLowerCase().contains('something') ||
                (t.time ?? '').toLowerCase().contains('something'),
          ),
          isTrue,
        );
      },
    );

    test(
      'getMonthlyChartData returns real mock fixture labels and values',
      () async {
        final chartData = await repository.getMonthlyChartData('January');
        expect(chartData, [
          ('Mon', 0.32),
          ('Tue', 0.48),
          ('Wed', 0.21),
          ('Thu', 0.66),
          ('Fri', 0.73),
          ('Sat', 0.39),
          ('Sun', 0.55),
        ]);
      },
    );
  });

  group('WalletController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Initial wallet state has no placeholder balance and starts loading',
      () {
        final state = container.read(walletControllerProvider);
        expect(state.availableBalance, 0);
        expect(state.isLoading, isTrue);
        expect(state.currentFilterIndex, equals(0));
        expect(state.selectedMonth, equals('January'));
        expect(state.moneyTypes, contains('Last Send'));
        expect(state.moneyTypes, contains('Last Receive'));
        expect(state.moneyTypes, contains('Total'));
      },
    );

    test('failed initial load can be retried and clears error state', () async {
      var attempts = 0;
      final failingThenSuccess = _RetryWalletRepository(
        onBalance: () async {
          attempts++;
          if (attempts == 1) throw StateError('temporary failure');
          return 123.45;
        },
      );
      final retryContainer = ProviderContainer(
        overrides: [
          walletRepositoryProvider.overrideWithValue(failingThenSuccess),
        ],
      );
      addTearDown(retryContainer.dispose);
      final controller = retryContainer.read(walletControllerProvider.notifier);

      await controller.loadInitialData();
      expect(
        retryContainer.read(walletControllerProvider).errorMessage,
        isNotNull,
      );
      expect(retryContainer.read(walletControllerProvider).isLoading, isFalse);

      await controller.retry();
      final state = retryContainer.read(walletControllerProvider);
      expect(attempts, greaterThanOrEqualTo(2));
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.availableBalance, 123.45);
      expect(state.cards, isNotEmpty);
    });

    test('repository locale remapping preserves wallet mutations', () async {
      final repository = WalletRepositoryImpl(
        null,
        null,
        const Locale('zh', 'CN'),
      );
      final before = await repository.getBankCards();
      expect(before, isNotEmpty);
      const added = BankCard(
        id: 'locale-mutation',
        bankName: 'Custom Bank',
        cardNumber: '1234',
        ownerName: 'User',
        expirationDate: '01/30',
      );
      await repository.addBankCard(added);
      await repository.deleteBankCard(before.last.id);
      await repository.refreshLocale(const Locale('en', 'US'));
      final after = await repository.getBankCards();
      expect(after.first.bankName, 'Northstar Credit Union');
      expect(after.any((card) => card.id == 'locale-mutation'), isTrue);
      expect(after.any((card) => card.id == before.last.id), isFalse);
      expect(await repository.getTransactions(), isNotEmpty);
    });

    test('loadInitialData populates cards and transactions', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.loadInitialData();

      final state = container.read(walletControllerProvider);
      expect(state.cards.isNotEmpty, isTrue);
      expect(state.transactions.isNotEmpty, isTrue);
      expect(state.isLoading, isFalse);
    });

    test(
      'setFilterIndex updates currentFilterIndex and refetches transactions',
      () async {
        final controller = container.read(walletControllerProvider.notifier);
        await controller.loadInitialData();

        // Switch to Receive (index 1)
        await controller.setFilterIndex(1);
        var state = container.read(walletControllerProvider);
        expect(state.currentFilterIndex, equals(1));
        expect(
          state.transactions.every((t) => (t.moneyAmount ?? 0) >= 0),
          isTrue,
        );

        // Switch to Total (index 2)
        await controller.setFilterIndex(2);
        state = container.read(walletControllerProvider);
        expect(state.currentFilterIndex, equals(2));
        expect(state.transactions.isNotEmpty, isTrue);
      },
    );

    test('selectCard updates selectedCardIndex', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.loadInitialData();
      controller.selectCard(2);

      final state = container.read(walletControllerProvider);
      expect(state.selectedCardIndex, equals(2));
    });

    test('selectMonth updates selectedMonth and chartData', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.selectMonth('February');

      final state = container.read(walletControllerProvider);
      expect(state.selectedMonth, equals('February'));
      expect(
        state.chartData.isEmpty,
        isTrue,
      ); // Never synthesize monthly percentages.
    });

    test('setSearchQuery filters transaction records', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.loadInitialData();

      await controller.setSearchQuery('NonExistentKeywordXYZ');
      final state = container.read(walletControllerProvider);
      expect(state.transactions.isEmpty, isTrue);
    });
  });

  group('AddCardController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial add card state is not valid for submission', () {
      final state = container.read(addCardControllerProvider);
      expect(state.isUserInputValid, isFalse);
      expect(state.cardRotateAngle, equals(AddCardState.cardMinRotateAngle));
    });

    test('Field setters validate correctly', () {
      final controller = container.read(addCardControllerProvider.notifier);

      // Owner Name
      controller.setOwnerName('');
      expect(
        container.read(addCardControllerProvider).ownerNameError,
        isNotNull,
      );
      controller.setOwnerName('John Doe');
      expect(container.read(addCardControllerProvider).ownerNameError, isNull);

      // Card Number
      controller.setCardNumber('');
      expect(
        container.read(addCardControllerProvider).cardNumberError,
        isNotNull,
      );
      controller.setCardNumber('1234567812345678');
      expect(container.read(addCardControllerProvider).cardNumberError, isNull);

      // Expire Date
      controller.setExpireDate(DateTime(2027, 8));
      expect(
        container.read(addCardControllerProvider).expireDateString,
        equals('08/27'),
      );
      expect(container.read(addCardControllerProvider).expireDateError, isNull);

      // CVV
      controller.setCvv('');
      expect(container.read(addCardControllerProvider).cvvError, isNotNull);
      controller.setCvv('1234');
      expect(container.read(addCardControllerProvider).cvvError, isNull);

      // Overall validation should now pass
      expect(
        container.read(addCardControllerProvider).isUserInputValid,
        isTrue,
      );
    });

    test('onBankCardPanUpdate clamps rotation angle within bounds', () {
      final controller = container.read(addCardControllerProvider.notifier);

      // Large drag downward
      controller.onBankCardPanUpdate(const Offset(0, 500));
      var angle = container.read(addCardControllerProvider).cardRotateAngle;
      expect(angle, greaterThanOrEqualTo(-AddCardState.cardMaxRotateAngle));
      expect(angle, lessThanOrEqualTo(AddCardState.cardMaxRotateAngle));

      // Reset
      controller.onBankCardPanUpdate(null);
      expect(
        container.read(addCardControllerProvider).cardRotateAngle,
        equals(AddCardState.cardMinRotateAngle),
      );
    });

    test(
      'addCard successfully saves card to repository and reloads cards',
      () async {
        final controller = container.read(addCardControllerProvider.notifier);
        final walletNotifier = container.read(
          walletControllerProvider.notifier,
        );
        await walletNotifier.loadInitialData();

        final initialCardsCount = container
            .read(walletControllerProvider)
            .cards
            .length;

        // Fill in valid details
        controller.setOwnerName('Michael Jordan');
        controller.setCardNumber('8888777766665555');
        controller.setExpireDate(DateTime(2029, 12));
        controller.setCvv('8888');

        final success = await controller.addCard();
        expect(success, isTrue);

        final updatedCards = container.read(walletControllerProvider).cards;
        expect(updatedCards.length, equals(initialCardsCount + 1));
        expect(
          updatedCards.any((c) => c.ownerName == 'Michael Jordan'),
          isTrue,
        );
      },
    );
  });
}
