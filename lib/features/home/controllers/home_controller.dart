import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/widgets/jingang_widget.dart';

part 'home_controller.g.dart';

/// 首页卡片数据模型（纯数据实体，不持有 UI Widget）
class BankCardItem {
  final String bankName;
  final String cardNumber;
  final String ownerName;
  final String expirationDate;

  const BankCardItem({
    required this.bankName,
    required this.cardNumber,
    required this.ownerName,
    required this.expirationDate,
  });
}

/// 首页看板状态（纯业务数据，不与 UI 组件或特定多语言文本耦合）
class HomeState {
  final int currentBankIndex;
  final List<double> weeklyPercentages;
  final List<BankCardItem> banks;
  final List<ImgText> quickActions;

  const HomeState({
    this.currentBankIndex = 0,
    required this.weeklyPercentages,
    required this.banks,
    required this.quickActions,
  });

  HomeState copyWith({
    int? currentBankIndex,
    List<double>? weeklyPercentages,
    List<BankCardItem>? banks,
    List<ImgText>? quickActions,
  }) {
    return HomeState(
      currentBankIndex: currentBankIndex ?? this.currentBankIndex,
      weeklyPercentages: weeklyPercentages ?? this.weeklyPercentages,
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
    return HomeState(
      weeklyPercentages: const [0.3, 0.5, 0.1, 0.6, 0.9, 0.2, 0.8],
      banks: const [
        BankCardItem(
          bankName: "CNSS",
          cardNumber: "8932 6283 3243 3232",
          ownerName: "Juan Perez",
          expirationDate: "02/20",
        ),
        BankCardItem(
          bankName: "DXSS",
          cardNumber: "8932 3223 3243 3232",
          ownerName: "Juan Perez",
          expirationDate: "12/29",
        ),
        BankCardItem(
          bankName: "CID",
          cardNumber: "8932 3283 3323 3232",
          ownerName: "Juan Perez",
          expirationDate: "11/22",
        ),
      ],
      quickActions: [
        ImgText("https://img.icons8.com/office/80/000000/bonds.png", "Bonds"),
        ImgText(
            "https://img.icons8.com/office/80/000000/billing.png", "Billing"),
        ImgText("https://img.icons8.com/office/80/000000/cash.png", "Cash"),
        ImgText("https://img.icons8.com/office/80/000000/money-bag.png",
            "Money Bag"),
        ImgText("https://img.icons8.com/office/80/000000/wallet.png", "Wallet"),
        ImgText("https://img.icons8.com/office/80/000000/bounced-check.png",
            "Bounced Check"),
        ImgText("https://img.icons8.com/office/80/000000/tax.png", "Tax"),
        ImgText("https://img.icons8.com/office/80/000000/purchase-order.png",
            "Purchase Order"),
        ImgText("https://img.icons8.com/office/80/000000/payment-history.png",
            "Payment History"),
        ImgText("https://img.icons8.com/office/80/000000/card-in-use.png",
            "Card In Use"),
        ImgText("https://img.icons8.com/office/80/000000/card-security.png",
            "Card Security"),
        ImgText(
            "https://img.icons8.com/office/80/000000/bank-card-front-side--v1.png",
            "Bank Card Front Side"),
        ImgText("https://img.icons8.com/office/80/000000/bank-card-missing.png",
            "bank card missing"),
        ImgText("https://img.icons8.com/office/80/000000/credit-control.png",
            "Credit Control"),
        ImgText("https://img.icons8.com/office/80/000000/commodity.png",
            "Commodity"),
      ],
    );
  }

  /// 设置当前选中的银行卡索引
  void setBankIndex(int index) {
    if (state.currentBankIndex != index) {
      state = state.copyWith(currentBankIndex: index);
    }
  }

  /// 更新折线图周百分比数据
  void updateWeeklyPercentages(List<double> percentages) {
    state = state.copyWith(weeklyPercentages: percentages);
  }
}
