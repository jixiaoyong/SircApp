import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

class _PendingCardsRepository extends WalletRepositoryImpl {
  final cards = Completer<List<BankCard>>();
  @override
  Future<double> getAvailableBalance() async => 0;
  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter filter = TransactionFilter.total,
    String? query,
  }) async => [];
  @override
  Future<List<(String, double)>> getMonthlyChartData(String month) async => [];
  @override
  Future<List<BankCard>> getBankCards() => cards.future;
}

void main() {
  for (final found in [false, true]) {
    testWidgets('编辑页自行查询卡片，加载后${found ? "填充表单" : "显示不存在"}', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _PendingCardsRepository();
      var backs = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [walletRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: CardEditorPage(editingId: 'target', onBack: () => backs++),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(Languages.wallet.cardLoading), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      repository.cards.complete(
        found
            ? [
                const BankCard(
                  id: 'target',
                  ownerName: 'Actual Owner',
                  cardNumber: '4111111111111111',
                  bankName: 'Test bank',
                  expirationDate: '12/29',
                  cardType: 'Visa',
                ),
              ]
            : [],
      );
      await tester.pump();
      await tester.pump();
      if (found) {
        expect(find.text('Actual Owner'), findsWidgets);
        expect(find.byType(BankCardWidget), findsOneWidget);
        final field = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(field.controller.text, 'Actual Owner');
        // Provider 更新不重置正在输入的表单。
        await tester.enterText(
          find.byType(EditableText).first,
          'Changed Owner',
        );
        await tester.pump();
        for (final width in [1200.0, 390.0]) {
          tester.view.physicalSize = Size(width, 1400);
          await tester.pump();
          expect(field.controller.text, 'Changed Owner');
        }
      } else {
        expect(find.text(Languages.wallet.cardNotFound), findsOneWidget);
        expect(find.byType(BankCardWidget), findsNothing);
      }
      await tester.tap(find.byType(BackButton));
      expect(backs, 1);
      expect(tester.takeException(), isNull);
    });
  }
  for (final brightness in Brightness.values) {
    testWidgets('添加卡保留预览、四位CVV和月份入口 $brightness', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const CardEditorPage(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(BankCardWidget), findsOneWidget);
      expect(find.text(Languages.nameOnCard), findsOneWidget);
      expect(find.text(Languages.cardNumber), findsOneWidget);
      expect(find.text('00/00'), findsWidgets);
      expect(
        tester
            .widget<VerifyCodeWidget>(find.byType(VerifyCodeWidget))
            .verifyCodeCount,
        4,
      );
      expect(
        tester
            .widget<CommonTextButton>(find.byType(CommonTextButton))
            .isButtonEnabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
