import 'package:flutter/material.dart';
import 'package:sirc/core/layout/app_layout.dart';
import 'package:sirc/routes/source_detail_navigation.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/settings_item_tile.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/card_management_page.dart';
import 'package:sirc/widgets/page_gutter.dart';

/// 只读个人资料；数据由导航控制器读取并映射用户 fixture。
class PersonInformationPage extends ConsumerWidget {
  const PersonInformationPage({super.key, required this.field, this.onBack});

  final String field;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final profile = ref.watch(personProfileProvider(locale));
    final savedEmail = ref.watch(storageServiceProvider).userEmail;
    final title = switch (field) {
      'email' => Languages.email,
      'phone' => Languages.phoneNumber,
      _ => Languages.localAddress,
    };
    final email = savedEmail?.trim().isNotEmpty == true ? savedEmail! : null;
    final value = profile.when(
      loading: () => Languages.loading,
      error: (_, _) => Languages.loadFailed,
      data: (data) => switch (field) {
        'email' => email ?? data.email,
        'phone' => data.phone.isNotEmpty ? data.phone : Languages.settings.notSet,
        _ => data.address.isNotEmpty ? data.address : Languages.settings.notSet,
      },
    );
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
final personProfileProvider = FutureProvider.family<UserProfile, Locale>(
  (ref, locale) => ref
      .read(navigationControllerProvider.notifier)
      .loadUserProfile(locale),
);

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
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final navState = ref.watch(navigationControllerProvider);
    final profile = ref.watch(personProfileProvider(locale));
    final profileValue = profile.asData?.value;
    final wallet = ref.watch(walletControllerProvider);
    final transactions = wallet.allTransactions;
    final spending = transactions
        .where((e) => (e.moneyAmount ?? 0) < 0)
        .fold<double>(0, (sum, e) => sum + (e.moneyAmount ?? 0).abs());
    final email = ref.watch(storageServiceProvider).userEmail ?? navState.userEmail;
    final profileData = profileValue;
    final displayName = profileData?.name ?? navState.userName;
    final displayAvatar = profileData?.avatarUrl ?? '';

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
                    tooltip: Languages.settings.openNavigationMenu,
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
                    message: Languages.settings.viewReadOnlyProfile,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: NetworkWebImage(
                        displayAvatar,
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
                  profile.isLoading
                      ? Languages.loading
                      : profile.hasError
                      ? Languages.loadFailed
                      : displayName,
                  style: TextStyle(fontSize: 20, color: AppColors.ink(context)),
                ),
              ),
              Text(
                Languages.totalSpending,
                style: TextStyle(fontSize: 16, color: AppColors.muted(context)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                child: wallet.isLoading
                    ? const SizedBox(
                        key: ValueKey('person-spending-loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : wallet.errorMessage != null
                    ? Text(
                        Languages.loadFailed,
                        key: const ValueKey('person-spending-error'),
                      )
                    : Text(
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
                    270 +
                    (MediaQuery.textScalerOf(context).scale(180) - 180).clamp(
                      0,
                      180,
                    ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wallet.isLoading || wallet.errorMessage != null
                      ? 0
                      : transactions.length,
                  itemBuilder: (context, index) {
                    final heroTag = "heroTag_$index";
                    final data = transactions[index].localizedPlaceholders.copyWith(
                      userIcon: displayAvatar,
                    );
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
                            270 +
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
                                  data.userIcon?.isNotEmpty == true
                            ? data.userIcon!
                            : displayAvatar,
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
                                ? '${email.isEmpty ? Languages.settings.notSet : email} · ${Languages.settings.readOnly}'
                                : index == 3
                                ? (Languages.settings.viewExistingWalletCards)
                                : '${Languages.settings.notSet} · ${Languages.settings.readOnly}',
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
