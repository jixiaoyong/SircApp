import 'dart:ui';

import 'package:sirc/features/wallet/domain/models/transaction.dart';

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

    test(
      'relative labels use injected local day, unknown dates remain unknown',
      () {
        for (final label in ['Just now', 'Today', '刚刚', '今天']) {
          expect(
            WalletState.transactionDate(Transaction(time: label), now: now),
            DateTime(2026, 11, 10),
          );
        }
        for (final label in ['Yesterday', '昨天']) {
          expect(
            WalletState.transactionDate(Transaction(time: label), now: now),
            DateTime(2026, 11, 9),
          );
        }
        for (final label in ['11/10', '10:30', 'unknown', '2026-02-30', '']) {
          expect(
            WalletState.transactionDate(Transaction(time: label), now: now),
            isNull,
          );
        }
        expect(
          WalletState.transactionDate(
            Transaction(time: '2026 / 11 / 09'),
            now: now,
          ),
          DateTime(2026, 11, 9),
        );
        expect(
          WalletState.transactionDate(
            Transaction(time: '2026-11-09T10:30:00'),
            now: now,
          ),
          DateTime(2026, 11, 9, 10, 30),
        );
        expect(
          WalletState.transactionDate(
            Transaction(time: 'Yesterday'),
            now: DateTime(2026, 1, 1),
          ),
          DateTime(2025, 12, 31),
        );
      },
    );

    test(
      'seven days, week boundaries, filters and zero preserve genuine volume',
      () {
        final data = state([
          for (var day = 9; day <= 15; day++)
            Transaction(
              time: '2026-11-${day.toString().padLeft(2, '0')}',
              moneyAmount: -day.toDouble(),
            ),
          Transaction(time: 'Just now', moneyAmount: 100),
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

  group('WalletRepository Tests', () {
    late WalletRepository repository;

    setUp(() {
      repository = WalletRepositoryImpl();
    });

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
        final english = WalletRepositoryImpl(
          null,
          null,
          const Locale('en', 'US'),
        );
        final chinese = WalletRepositoryImpl(
          null,
          null,
          const Locale('zh', 'CN'),
        );
        expect(await english.getAvailableBalance(), 39615.16);
        expect(
          (await english.getBankCards()).first.bankName,
          'Northstar Credit Union',
        );
        expect((await chinese.getBankCards()).first.bankName, '北辰信用社');
        expect(
          (await english.getTransactions()).first.moneyActionName,
          'Cornerstone Coffee',
        );
        expect((await chinese.getTransactions()).first.moneyActionName, '基石咖啡');
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

    test('Initial wallet state has no placeholder balance and starts loading', () {
      final state = container.read(walletControllerProvider);
      expect(state.availableBalance, 0);
      expect(state.isLoading, isTrue);
      expect(state.currentFilterIndex, equals(0));
      expect(state.selectedMonth, equals('January'));
      expect(state.moneyTypes, contains('Last Send'));
      expect(state.moneyTypes, contains('Last Receive'));
      expect(state.moneyTypes, contains('Total'));
    });

    test('failed initial load can be retried and clears error state', () async {
      var attempts = 0;
      final failingThenSuccess = _RetryWalletRepository(onBalance: () async {
        attempts++;
        if (attempts == 1) throw StateError('temporary failure');
        return 123.45;
      });
      final retryContainer = ProviderContainer(
        overrides: [walletRepositoryProvider.overrideWithValue(failingThenSuccess)],
      );
      addTearDown(retryContainer.dispose);
      final controller = retryContainer.read(walletControllerProvider.notifier);

      await controller.loadInitialData();
      expect(retryContainer.read(walletControllerProvider).errorMessage, isNotNull);
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
      final repository = WalletRepositoryImpl(null, null, const Locale('zh', 'CN'));
      final before = await repository.getBankCards();
      expect(before, isNotEmpty);
      const added = BankCard(
        id: 'locale-mutation', bankName: 'Custom Bank', cardNumber: '1234',
        ownerName: 'User', expirationDate: '01/30',
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
