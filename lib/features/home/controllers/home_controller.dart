import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

part 'home_controller.g.dart';

/// 首页卡片数据模型（纯数据实体，不持有 UI Widget）
class BankCardItem {
  final String bankName;
  final String cardNumber;
  final String ownerName;
  final String expirationDate;
  final String? cardType;

  const BankCardItem({
    required this.bankName,
    required this.cardNumber,
    required this.ownerName,
    required this.expirationDate,
    this.cardType,
  });
}

/// 首页看板状态（纯业务数据，不与 UI 组件或特定多语言文本耦合）
class HomeState {
  final int currentBankIndex;
  final List<BankCardItem> banks;
  final List<ImgText> quickActions;

  const HomeState({
    this.currentBankIndex = 0,
    required this.banks,
    required this.quickActions,
  });

  HomeState copyWith({
    int? currentBankIndex,
    List<BankCardItem>? banks,
    List<ImgText>? quickActions,
  }) {
    return HomeState(
      currentBankIndex: currentBankIndex ?? this.currentBankIndex,
      banks: banks ?? this.banks,
      quickActions: quickActions ?? this.quickActions,
    );
  }
}

/// 首页控制器（纯业务逻辑，不与多语言直接耦合）
@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() {
    final wallet = ref.watch(walletControllerProvider);
    return HomeState(
      currentBankIndex: wallet.selectedCardIndex,
      banks: wallet.cards
          .map(
            (card) => BankCardItem(
              bankName: card.bankName,
              cardNumber: card.cardNumber,
              ownerName: card.ownerName,
              expirationDate: card.expirationDate,
              cardType: card.cardType,
            ),
          )
          .toList(),
      quickActions: [
        ImgText("https://img.icons8.com/office/80/000000/bonds.png", "Bonds"),
        ImgText(
          "https://img.icons8.com/office/80/000000/billing.png",
          "Billing",
        ),
        ImgText("https://img.icons8.com/office/80/000000/cash.png", "Cash"),
        ImgText(
          "https://img.icons8.com/office/80/000000/money-bag.png",
          "Money Bag",
        ),
        ImgText("https://img.icons8.com/office/80/000000/wallet.png", "Wallet"),
        ImgText(
          "https://img.icons8.com/office/80/000000/bounced-check.png",
          "Bounced Check",
        ),
        ImgText("https://img.icons8.com/office/80/000000/tax.png", "Tax"),
        ImgText(
          "https://img.icons8.com/office/80/000000/purchase-order.png",
          "Purchase Order",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/payment-history.png",
          "Payment History",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/card-in-use.png",
          "Card In Use",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/card-security.png",
          "Card Security",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/bank-card-front-side--v1.png",
          "Bank Card Front Side",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/bank-card-missing.png",
          "bank card missing",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/credit-control.png",
          "Credit Control",
        ),
        ImgText(
          "https://img.icons8.com/office/80/000000/commodity.png",
          "Commodity",
        ),
      ],
    );
  }

  /// 设置当前选中的银行卡索引
  void setBankIndex(int index) {
    ref.read(walletControllerProvider.notifier).selectCard(index);
  }
}
