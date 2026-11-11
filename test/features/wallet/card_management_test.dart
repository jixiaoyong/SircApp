import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/card_management_page.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';

void main() {
  test('edit/delete use stable ID, preserve selection and transactions, never store CVV', () async {
    final repository = WalletRepositoryImpl();
    final container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final wallet = container.read(walletControllerProvider.notifier);
    await wallet.loadInitialData();
    final history = container.read(walletControllerProvider).allTransactions;
    wallet.selectCard(1);
    await wallet.deleteCard('1');
    expect(
      container
          .read(walletControllerProvider)
          .cards[container.read(walletControllerProvider).selectedCardIndex]
          .id,
      '2',
    );
    final editor = container.read(addCardControllerProvider.notifier);
    final subscription = container.listen(addCardControllerProvider, (_, _) {});
    addTearDown(subscription.close);
    final card = (await repository.getBankCards()).first;
    editor.startEditing(card);
    expect(container.read(addCardControllerProvider).cvv, isEmpty);
    editor.setOwnerName('Edited Owner');
    editor.setCvv('123');
    expect(await editor.addCard(), isFalse);
    editor.setCvv('1234');
    expect(await editor.addCard(), isTrue);
    final saved = (await repository.getBankCards()).first;
    expect(saved.id, card.id);
    expect(saved.ownerName, 'Edited Owner');
    expect(saved.cvv, isNull);
    expect(
      container.read(homeControllerProvider).banks.first.ownerName,
      'Edited Owner',
    );
    expect(container.read(walletControllerProvider).allTransactions, history);
    for (final card in [...container.read(walletControllerProvider).cards]) {
      await wallet.deleteCard(card.id);
    }
    expect(container.read(walletControllerProvider).cards, isEmpty);
    expect(container.read(walletControllerProvider).selectedCardIndex, 0);
    expect(container.read(homeControllerProvider).banks, isEmpty);
    expect(container.read(walletControllerProvider).allTransactions, history);
  });

  testWidgets('shared list style supports long text and large type at 320', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = WalletRepositoryImpl();
    await repository.updateBankCard(
      const BankCard(
        id: '1',
        bankName: 'A very long international bank name that wraps naturally',
        cardNumber: '8932 6283 3243 3232',
        ownerName: 'A long card owner name for accessibility testing',
        expirationDate: '08/29',
        cardType: 'MasterCard',
      ),
    );
    final container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const CardManagementPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('8932 6283 3243 3232'), findsNothing);
    for (final action in ['edit', 'delete']) {
      final size = tester.getSize(find.byKey(ValueKey('$action-card-1')));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
    expect(find.byType(Divider), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1000.0]) {
    testWidgets('masked list and delete cancel/confirm at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = WalletRepositoryImpl();
      final container = ProviderContainer(
        overrides: [walletRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CardManagementPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('8932 6283 3243 3232'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('delete-card-1')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await repository.getBankCards()).length, 3);
      await tester.tap(find.byKey(const ValueKey('delete-card-1')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect((await repository.getBankCards()).map((card) => card.id), [
        '2',
        '3',
      ]);
      expect(tester.takeException(), isNull);
    });
  }
}
