import 'package:flutter/material.dart';
import 'package:sirc/core/layout/app_layout.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/settings_item_tile.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/card_management_page.dart';
import 'package:sirc/widgets/page_gutter.dart';

/// 只读个人资料；电话和地址尚无数据源，不虚构用户信息。
class PersonInformationPage extends ConsumerWidget {
  const PersonInformationPage({super.key, required this.field, this.onBack});

  final String field;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final user = ref.watch(navigationControllerProvider);
    final savedEmail = ref.watch(storageServiceProvider).userEmail;
    final title = switch (field) {
      'email' => Languages.email,
      'phone' => Languages.phoneNumber,
      _ => Languages.localAddress,
    };
    final email = savedEmail?.trim().isNotEmpty == true
        ? savedEmail!
        : user.userEmail;
    final value = field == 'email' && email.trim().isNotEmpty
        ? email
        : Languages.settings.notSet;
    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(title: title, onBack: onBack),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SelectableText(
          value,
          key: const ValueKey('person-information-value'),
        ),
      ),
    );
  }
}

/// 保留 person/card 的来源与返回语义，复用钱包的统一卡片管理。
class PersonCardsPage extends StatelessWidget {
  const PersonCardsPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) =>
      CardManagementPage(onBack: onBack ?? () => context.go(AppRoutes.PERSON));
}

/// 个人中心页面，用户信息展示、流水列表与通用信息
class PersonPage extends ConsumerStatefulWidget {
  const PersonPage({super.key});

  @override
  ConsumerState<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends ConsumerState<PersonPage> {
  late List<Transaction> _moneyOperateList;
  final _scrollController = ScrollController();
  bool? _wasWide;
  final _scrollOffsets = <bool, double>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wide = AppLayout.isWideWindow(context);
    if (_wasWide != null && _wasWide != wide) {
      if (_scrollController.hasClients) {
        _scrollOffsets[_wasWide!] = _scrollController.offset;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpTo(
          (_scrollOffsets[wide] ?? 0).clamp(
            0,
            _scrollController.position.maxScrollExtent,
          ),
        );
      });
    }
    _wasWide = wide;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _moneyOperateList = MockUtils.moneyOperateList
        .map<Transaction>(
          (e) => e.copyWith(
            userIcon: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final navState = ref.watch(navigationControllerProvider);
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final spending = ref
        .watch(walletControllerProvider)
        .allTransactions
        .where((e) => (e.moneyAmount ?? 0) < 0)
        .fold<double>(0, (sum, e) => sum + (e.moneyAmount ?? 0).abs());
    final email =
        ref.watch(storageServiceProvider).userEmail ?? navState.userEmail;

    final generalInformationList = [
      (Icons.email_outlined, Languages.email, AppRoutes.PERSON_EMAIL),
      (Icons.phone_outlined, Languages.phoneNumber, AppRoutes.PERSON_PHONE),
      (
        Icons.location_on_outlined,
        Languages.localAddress,
        AppRoutes.PERSON_ADDRESS,
      ),
      (Icons.credit_card_outlined, Languages.cardCredit, AppRoutes.PERSON_CARD),
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      child: SafeArea(
        child: PageGutter(
          maxWidth: 1017,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: zh ? '打开导航菜单' : 'Open navigation menu',
                    onPressed: () {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer();
                    },
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.PERSON_EMAIL);
                  },
                  child: Tooltip(
                    message: zh ? '查看只读个人资料' : 'View read-only profile',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: NetworkWebImage(
                        navState.userAvatar,
                        size: Size(100, 100),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
                child: Text(
                  navState.userName,
                  style: TextStyle(fontSize: 20, color: AppColors.ink(context)),
                ),
              ),
              Text(
                Languages.totalSpending,
                style: TextStyle(fontSize: 16, color: AppColors.muted(context)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                child: Text(
                  '\$${spending.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.expense(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height:
                    240 +
                    (MediaQuery.textScalerOf(context).scale(180) - 180).clamp(
                      0,
                      180,
                    ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _moneyOperateList.length,
                  itemBuilder: (context, index) {
                    final heroTag = "heroTag_$index";
                    final data = _moneyOperateList[index].localizedPlaceholders;
                    final textColor = AppColors.ink(context);

                    return GestureDetector(
                      onTap: () {
                        openSourceDetail(
                          context,
                          AppRoutes.TRANSACTION_SEGMENT,
                          extra: {"data": data, "heroTag": heroTag},
                        );
                      },
                      child: Container(
                        height:
                            240 +
                            (MediaQuery.textScalerOf(context).scale(180) - 180)
                                .clamp(0, 180),
                        width: 150,
                        margin: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.line(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: NetworkWebImage(
                                  data.userIcon!,
                                  size: Size.square(50),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                data.moneyAmount.toFormatedMoneyStr,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: (data.moneyAmount ?? 0) < 0
                                      ? AppColors.expense(context)
                                      : AppColors.income(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              data.moneyActionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 18, color: textColor),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                data.time!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line(context)),
                ),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Text(
                          Languages.generalInformation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...generalInformationList.asMap().entries.expand((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return [
                          SettingsItemTile(
                            icon: item.$1,
                            title: item.$2,
                            subtitle: index == 0
                                ? '${email.isEmpty ? Languages.settings.notSet : email} · ${zh ? '只读' : 'Read only'}'
                                : index == 3
                                ? (zh
                                      ? '查看钱包中的现有银行卡'
                                      : 'View existing wallet cards')
                                : '${Languages.settings.notSet} · ${zh ? '只读' : 'Read only'}',
                            onTap: () {
                              final router = GoRouter.of(context);
                              final current = router
                                  .routeInformationProvider
                                  .value
                                  .uri
                                  .path;
                              if (current == item.$3) return;
                              if (AppLayout.isWideWindow(context) &&
                                  current.startsWith('${AppRoutes.PERSON}/') &&
                                  current !=
                                      '${AppRoutes.PERSON}/${AppRoutes.TRANSACTION_SEGMENT}') {
                                Router.neglect(
                                  context,
                                  () => router.replace<void>(item.$3),
                                );
                              } else {
                                context.push(item.$3);
                              }
                            },
                          ),
                          if (index != generalInformationList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: AppColors.muted(context)
                                  .withValues(alpha: 0.2),
                            ),
                        ];
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
