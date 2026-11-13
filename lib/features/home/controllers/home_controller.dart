import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:sirc/widgets/jingang_widget.dart';

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
  final List<List<Map<String, dynamic>>> articleGroups;

  const HomeState({
    this.articleGroups = const [],
    this.currentBankIndex = 0,
    required this.banks,
    required this.quickActions,
  });

  HomeState copyWith({
    int? currentBankIndex,
    List<BankCardItem>? banks,
    List<ImgText>? quickActions,
    List<List<Map<String, dynamic>>>? articleGroups,
  }) {
    return HomeState(
      currentBankIndex: currentBankIndex ?? this.currentBankIndex,
      banks: banks ?? this.banks,
      quickActions: quickActions ?? this.quickActions,
      articleGroups: articleGroups ?? this.articleGroups,
    );
  }
}

/// 首页控制器（纯业务逻辑，不与多语言直接耦合）
@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() {
    final wallet = ref.watch(walletControllerProvider);
    final mock = ref.watch(mockDataRepositoryProvider);
    final locale = ref.watch(localeProvider);
    Future.microtask(() async {
      try {
        final groups = await mock.getArticleGroups(locale);
        final actions = await mock.getQuickActions(locale);
        if (!ref.mounted) return;
        state = state.copyWith(
          articleGroups: groups,
          quickActions: actions
              .map(
                (item) => ImgText(
                  item['imageUrl'] as String? ?? '',
                  item['title'] as String? ?? '',
                ),
              )
              .toList(),
        );
      } catch (_) {
        // Keep the UI usable when optional static home content is unavailable.
      }
    });
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
      quickActions: const [],
    );
  }

  /// 设置当前选中的银行卡索引
  void setBankIndex(int index) {
    ref.read(walletControllerProvider.notifier).selectCard(index);
  }
}
