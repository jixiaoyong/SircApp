import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/config/app_author.dart';
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
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/constrained_content.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (title, iconData) = switch (field) {
      'email' => (Languages.email, Icons.mark_email_read_outlined),
      'phone' => (Languages.phoneNumber, Icons.phone_android_outlined),
      _ => (Languages.localAddress, Icons.home_work_outlined),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ConstrainedContent(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Credential Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(iconData, color: colors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      Languages.settings.credentialVerified,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Languages.settings.securityCredential,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            value,
                            key: const ValueKey('person-information-value'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: Text(Languages.settings.copyLogs),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: value));
                          Toast.show(Languages.settings.copiedToClipboard);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Security & Privacy Explanation Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Languages.settings.accountSecurity,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Languages.settings.securityProtection,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showDialog<void>(
                      context: context,
                      builder: (dContext) => AlertDialog(
                        title: Text(Languages.settings.rebind),
                        content: Text(
                          Languages.settings.securityProtection,
                        ),
                        actions: [
                          TextButton(
                            child: Text(Languages.submit),
                            onPressed: () => Navigator.of(dContext).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sync_lock_outlined, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          Languages.settings.rebind,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                    HapticFeedback.lightImpact();
                    _showUserProfileSheet(
                      context: context,
                      profileData: profileData,
                      displayName: displayName,
                      displayAvatar: displayAvatar,
                      email: email,
                    );
                  },
                  child: Tooltip(
                    message: Languages.settings.userProfileTitle,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: NetworkWebImage(
                        displayAvatar,
                        size: Size(100, 100),
                        fit: BoxFit.cover,
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

                        final subtitle = index == 0
                            ? '${email.isEmpty ? Languages.settings.notSet : email} · ${Languages.settings.readOnly}'
                            : index == 3
                            ? (Languages.settings.viewExistingWalletCards)
                            : '${Languages.settings.notSet} · ${Languages.settings.readOnly}';

                        return [
                          SettingsItemTile(
                            icon: item.$1,
                            title: item.$2,
                            subtitle: subtitle,
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

void _showUserProfileSheet({
  required BuildContext context,
  required UserProfile? profileData,
  required String displayName,
  required String displayAvatar,
  required String email,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ClipOval(
                child: NetworkWebImage(
                  displayAvatar,
                  size: const Size(80, 80),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email.isNotEmpty ? email : AppAuthor.email,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Languages.settings.credentialVerified,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // UID Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Text(
                      'UID: 8829420',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(const ClipboardData(text: '8829420'));
                        Toast.show(Languages.settings.copiedToClipboard);
                      },
                      child: Icon(Icons.copy_rounded, size: 16, color: colors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(Languages.cancel),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
