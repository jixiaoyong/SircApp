import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

void main() {
  setUpAll(() {
    AppLocale.setLocale(const Locale('en', 'US'));
  });

  group('WalletRepository Tests', () {
    late WalletRepository repository;

    setUp(() {
      repository = WalletRepositoryImpl();
    });

    test('Initial bank cards should not be empty and contain default cards', () async {
      final cards = await repository.getBankCards();
      expect(cards.length, greaterThanOrEqualTo(3));
      expect(cards.any((c) => c.bankName == 'CNSS'), isTrue);
    });

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
      expect((await repository.getBankCards()).any((c) => c.id == 'to_delete_id'), isTrue);

      await repository.deleteBankCard('to_delete_id');
      expect((await repository.getBankCards()).any((c) => c.id == 'to_delete_id'), isFalse);
    });

    test('getTransactions with TransactionFilter.send filters negative amounts', () async {
      final sendTxs = await repository.getTransactions(filter: TransactionFilter.send);
      expect(sendTxs.every((item) => (item.moneyAmount ?? 0) < 0), isTrue);
    });

    test('getTransactions with TransactionFilter.receive filters positive amounts', () async {
      final receiveTxs = await repository.getTransactions(filter: TransactionFilter.receive);
      expect(receiveTxs.every((item) => (item.moneyAmount ?? 0) >= 0), isTrue);
    });

    test('getTransactions with TransactionFilter.total returns all items', () async {
      final totalTxs = await repository.getTransactions(filter: TransactionFilter.total);
      final sendTxs = await repository.getTransactions(filter: TransactionFilter.send);
      final receiveTxs = await repository.getTransactions(filter: TransactionFilter.receive);

      expect(totalTxs.length, equals(sendTxs.length + receiveTxs.length));
    });

    test('getTransactions with search query filters action name or time', () async {
      final txs = await repository.getTransactions(query: 'Something');
      expect(txs.every((t) => (t.moneyActionName ?? '').toLowerCase().contains('something') || (t.time ?? '').toLowerCase().contains('something')), isTrue);
    });

    test('getMonthlyChartData returns Dart 3 records', () async {
      final chartData = await repository.getMonthlyChartData('January');
      expect(chartData.isNotEmpty, isTrue);
      expect(chartData.first.$1, isNotEmpty);
      expect(chartData.first.$2, inInclusiveRange(0.0, 1.0));
    });
  });

  group('WalletController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial wallet state defaults', () {
      final state = container.read(walletControllerProvider);
      expect(state.currentFilterIndex, equals(0));
      expect(state.selectedMonth, equals('January'));
      expect(state.moneyTypes, contains('Last Send'));
      expect(state.moneyTypes, contains('Last Receive'));
      expect(state.moneyTypes, contains('Total'));
    });

    test('loadInitialData populates cards and transactions', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.loadInitialData();

      final state = container.read(walletControllerProvider);
      expect(state.cards.isNotEmpty, isTrue);
      expect(state.transactions.isNotEmpty, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('setFilterIndex updates currentFilterIndex and refetches transactions', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.loadInitialData();

      // Switch to Receive (index 1)
      await controller.setFilterIndex(1);
      var state = container.read(walletControllerProvider);
      expect(state.currentFilterIndex, equals(1));
      expect(state.transactions.every((t) => (t.moneyAmount ?? 0) >= 0), isTrue);

      // Switch to Total (index 2)
      await controller.setFilterIndex(2);
      state = container.read(walletControllerProvider);
      expect(state.currentFilterIndex, equals(2));
      expect(state.transactions.isNotEmpty, isTrue);
    });

    test('selectCard updates selectedCardIndex', () {
      final controller = container.read(walletControllerProvider.notifier);
      controller.selectCard(2);

      final state = container.read(walletControllerProvider);
      expect(state.selectedCardIndex, equals(2));
    });

    test('selectMonth updates selectedMonth and chartData', () async {
      final controller = container.read(walletControllerProvider.notifier);
      await controller.selectMonth('February');

      final state = container.read(walletControllerProvider);
      expect(state.selectedMonth, equals('February'));
      expect(state.chartData.isNotEmpty, isTrue);
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
      expect(container.read(addCardControllerProvider).ownerNameError, isNotNull);
      controller.setOwnerName('John Doe');
      expect(container.read(addCardControllerProvider).ownerNameError, isNull);

      // Card Number
      controller.setCardNumber('');
      expect(container.read(addCardControllerProvider).cardNumberError, isNotNull);
      controller.setCardNumber('1234567812345678');
      expect(container.read(addCardControllerProvider).cardNumberError, isNull);

      // Expire Date
      controller.setExpireDate(DateTime(2027, 8));
      expect(container.read(addCardControllerProvider).expireDateString, equals('08/27'));
      expect(container.read(addCardControllerProvider).expireDateError, isNull);

      // CVV
      controller.setCvv('');
      expect(container.read(addCardControllerProvider).cvvError, isNotNull);
      controller.setCvv('123');
      expect(container.read(addCardControllerProvider).cvvError, isNull);

      // Overall validation should now pass
      expect(container.read(addCardControllerProvider).isUserInputValid, isTrue);
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
      expect(container.read(addCardControllerProvider).cardRotateAngle, equals(AddCardState.cardMinRotateAngle));
    });

    test('addCard successfully saves card to repository and reloads cards', () async {
      final controller = container.read(addCardControllerProvider.notifier);
      final walletNotifier = container.read(walletControllerProvider.notifier);
      await walletNotifier.loadInitialData();

      final initialCardsCount = container.read(walletControllerProvider).cards.length;

      // Fill in valid details
      controller.setOwnerName('Michael Jordan');
      controller.setCardNumber('8888777766665555');
      controller.setExpireDate(DateTime(2029, 12));
      controller.setCvv('888');

      final success = await controller.addCard();
      expect(success, isTrue);

      final updatedCards = container.read(walletControllerProvider).cards;
      expect(updatedCards.length, equals(initialCardsCount + 1));
      expect(updatedCards.any((c) => c.ownerName == 'Michael Jordan'), isTrue);
    });
  });
}
