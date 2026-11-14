import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/mock/mock_data_repository.dart';

void main() {
  late MockDataRepository mock;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mock = MockDataRepository();
    await mock.wallet;
  });

  test('BankCard CRUD persists across WalletRepository instances via StorageService', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    // 1. Initial load from mock fixtures
    final repo1 = WalletRepositoryImpl(
      null,
      mock,
      const Locale('zh'),
      null,
      storage,
    );
    final initialCards = await repo1.getBankCards();
    expect(initialCards.isNotEmpty, isTrue);
    final initialCount = initialCards.length;

    // 2. Add a new bank card
    const newCard = BankCard(
      id: 'persisted-test-card-999',
      bankName: 'Persisted Test Bank',
      cardNumber: '1111 2222 3333 4444',
      ownerName: 'Persistence Tester',
      expirationDate: '12/30',
      cardType: 'Visa',
    );
    await repo1.addBankCard(newCard);

    final cardsAfterAdd = await repo1.getBankCards();
    expect(cardsAfterAdd.length, initialCount + 1);
    expect(cardsAfterAdd.any((c) => c.id == 'persisted-test-card-999'), isTrue);

    // 3. Second fresh instance with clean memory, reading same storage
    final repo2 = WalletRepositoryImpl(
      null,
      mock,
      const Locale('zh'),
      null,
      storage,
    );
    final repo2Cards = await repo2.getBankCards();
    expect(repo2Cards.length, initialCount + 1);
    final loadedAddedCard = repo2Cards.firstWhere((c) => c.id == 'persisted-test-card-999');
    expect(loadedAddedCard.bankName, 'Persisted Test Bank');
    expect(loadedAddedCard.ownerName, 'Persistence Tester');

    // 4. Update an existing card
    final cardToUpdate = initialCards.first;
    final updatedCard = cardToUpdate.copyWith(ownerName: 'Updated Owner Name');
    await repo2.updateBankCard(updatedCard);

    // 5. Third fresh instance verifies the override persisted
    final repo3 = WalletRepositoryImpl(
      null,
      mock,
      const Locale('zh'),
      null,
      storage,
    );
    final repo3Cards = await repo3.getBankCards();
    final loadedUpdatedCard = repo3Cards.firstWhere((c) => c.id == cardToUpdate.id);
    expect(loadedUpdatedCard.ownerName, 'Updated Owner Name');

    // 6. Delete both the added card and the base card
    await repo3.deleteBankCard('persisted-test-card-999');
    await repo3.deleteBankCard(cardToUpdate.id);

    // 7. Fourth fresh instance verifies deletions persisted
    final repo4 = WalletRepositoryImpl(
      null,
      mock,
      const Locale('zh'),
      null,
      storage,
    );
    final repo4Cards = await repo4.getBankCards();
    expect(repo4Cards.any((c) => c.id == 'persisted-test-card-999'), isFalse);
    expect(repo4Cards.any((c) => c.id == cardToUpdate.id), isFalse);
    expect(repo4Cards.length, initialCount - 1);
  });
}
