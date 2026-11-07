import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/jingang_widget.dart';

/// 首页卡片数据模型
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

/// 首页看板状态
class HomeState {
  final int currentBankIndex;
  final double homeAppBarFlexibleWidgetHeight;
  final List<(String day, double percentage)> dataChange;
  final List<(String name, int id)> tabData;
  final List<ImgText> quickActions;
  final List<BankCardWidget> banks;

  const HomeState({
    this.currentBankIndex = 0,
    this.homeAppBarFlexibleWidgetHeight = 0.0,
    required this.dataChange,
    required this.tabData,
    required this.quickActions,
    required this.banks,
  });

  HomeState copyWith({
    int? currentBankIndex,
    double? homeAppBarFlexibleWidgetHeight,
    List<(String, double)>? dataChange,
    List<(String, int)>? tabData,
    List<ImgText>? quickActions,
    List<BankCardWidget>? banks,
  }) {
    return HomeState(
      currentBankIndex: currentBankIndex ?? this.currentBankIndex,
      homeAppBarFlexibleWidgetHeight:
          homeAppBarFlexibleWidgetHeight ?? this.homeAppBarFlexibleWidgetHeight,
      dataChange: dataChange ?? this.dataChange,
      tabData: tabData ?? this.tabData,
      quickActions: quickActions ?? this.quickActions,
      banks: banks ?? this.banks,
    );
  }
}

/// 首页控制器
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    // 监听全局语言变更，自动重新求值所有本地化文本
    ref.watch(localeProvider);

    final previousState = stateOrNull;
    if (previousState != null) {
      return previousState.copyWith(
        dataChange: [
          ("Mon".tr, 0.3),
          ("Tues".tr, 0.5),
          ("Wed".tr, 0.1),
          ("Thur".tr, 0.6),
          ("Fri".tr, 0.9),
          ("Satu".tr, 0.2),
          ("Sun".tr, 0.8),
        ],
        tabData: [
          ("Follow".tr, 0x0),
          ("Hot".tr, 0x1),
          ("Explore".tr, 0x2),
        ],
        banks: [
          BankCardWidget(
            bankName: "CNSS".tr,
            cardNumber: "8932 6283 3243 3232",
            ownerName: "Juan Perez",
            expirationDate: "02/20",
          ),
          BankCardWidget(
            bankName: "DXSS".tr,
            cardNumber: "8932 3223 3243 3232",
            ownerName: "Juan Perez",
            expirationDate: "12/29",
          ),
          BankCardWidget(
            bankName: "CID".tr,
            cardNumber: "8932 3283 3323 3232",
            ownerName: "Juan Perez",
            expirationDate: "11/22",
          ),
        ],
      );
    }

    return HomeState(
      dataChange: [
        ("Mon".tr, 0.3),
        ("Tues".tr, 0.5),
        ("Wed".tr, 0.1),
        ("Thur".tr, 0.6),
        ("Fri".tr, 0.9),
        ("Satu".tr, 0.2),
        ("Sun".tr, 0.8),
      ],
      tabData: [
        ("Follow".tr, 0x0),
        ("Hot".tr, 0x1),
        ("Explore".tr, 0x2),
      ],
      quickActions: [
        ImgText("https://img.icons8.com/office/80/000000/bonds.png", "Bonds"),
        ImgText("https://img.icons8.com/office/80/000000/billing.png", "Billing"),
        ImgText("https://img.icons8.com/office/80/000000/cash.png", "Cash"),
        ImgText("https://img.icons8.com/office/80/000000/money-bag.png", "Money Bag"),
        ImgText("https://img.icons8.com/office/80/000000/wallet.png", "Wallet"),
        ImgText("https://img.icons8.com/office/80/000000/bounced-check.png", "Bounced Check"),
        ImgText("https://img.icons8.com/office/80/000000/tax.png", "Tax"),
        ImgText("https://img.icons8.com/office/80/000000/purchase-order.png", "Purchase Order"),
        ImgText("https://img.icons8.com/office/80/000000/payment-history.png", "Payment History"),
        ImgText("https://img.icons8.com/office/80/000000/card-in-use.png", "Card In Use"),
        ImgText("https://img.icons8.com/office/80/000000/card-security.png", "Card Security"),
        ImgText("https://img.icons8.com/office/80/000000/bank-card-front-side--v1.png", "Bank Card Front Side"),
        ImgText("https://img.icons8.com/office/80/000000/bank-card-missing.png", "bank card missing"),
        ImgText("https://img.icons8.com/office/80/000000/credit-control.png", "Credit Control"),
        ImgText("https://img.icons8.com/office/80/000000/commodity.png", "Commodity"),
      ],
      banks: [
        BankCardWidget(
          bankName: "CNSS".tr,
          cardNumber: "8932 6283 3243 3232",
          ownerName: "Juan Perez",
          expirationDate: "02/20",
        ),
        BankCardWidget(
          bankName: "DXSS".tr,
          cardNumber: "8932 3223 3243 3232",
          ownerName: "Juan Perez",
          expirationDate: "12/29",
        ),
        BankCardWidget(
          bankName: "CID".tr,
          cardNumber: "8932 3283 3323 3232",
          ownerName: "Juan Perez",
          expirationDate: "11/22",
        ),
      ],
    );
  }

  /// 设置当前选中的银行卡索引
  void setBankIndex(int index) {
    if (state.currentBankIndex != index) {
      state = state.copyWith(currentBankIndex: index);
    }
  }

  /// 记录 SliverAppBar 的 FlexibleSpaceBar 高度
  void onFlexibleSpaceBarSizeChange(double height) {
    if (state.homeAppBarFlexibleWidgetHeight != height) {
      state = state.copyWith(homeAppBarFlexibleWidgetHeight: height);
    }
  }

  /// 更新收支折线图周数据
  void updateWeeklyData(List<(String, double)> data) {
    state = state.copyWith(dataChange: data);
  }
}

/// 首页控制器 Provider
final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
