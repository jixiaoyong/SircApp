import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/domain/utils/transaction_category_helper.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/date_time_formatter.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/// 钱包业务负责解析旧入口参数与缺失数据；路由不补造交易。
class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({
    super.key,
    required this.data,
    required this.heroTag,
  });

  factory TransactionDetailPage.fromExtra({Key? key, Object? extra}) {
    final candidate = extra is Map ? extra['data'] : extra;
    final tag = extra is Map ? extra['heroTag'] : null;
    return TransactionDetailPage(
      key: key,
      data: candidate is Transaction ? candidate : null,
      heroTag: tag is String ? tag : 'default',
    );
  }

  final Transaction? data;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final transaction = data;
    final appBar = OneTitleWithBackButtonAppBar(
      title: Languages.wallet.transactionDetails,
    );
    if (transaction == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: Text(Languages.wallet.transactionUnavailable)),
      );
    }
    final amountColor = (transaction.moneyAmount ?? 0) < 0
        ? AppColors.expense(context)
        : AppColors.income(context);
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  TransactionCategoryHelper.buildAdaptiveCategoryAvatar(
                    context: context,
                    transaction: transaction,
                    heroTag: heroTag,
                    size: 72,
                    iconSize: 36,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    transaction.moneyActionName ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.moneyAmount.toFormatedMoneyStr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppDateTimeFormatter.display(
                      transaction.time,
                      locale: locale,
                      languages: AppLocale.current,
                    ),
                    style: TextStyle(color: AppColors.muted(context)),
                  ),
                  const SizedBox(height: 32),
                  WalletPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.wallet.transactionType,
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(transaction.moneyActionName ?? ''),
                        const Divider(height: 32),
                        Text(
                          Languages.wallet.amount,
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          transaction.moneyAmount.toFormatedMoneyStr,
                          style: TextStyle(color: amountColor),
                        ),
                        const Divider(height: 32),
                        Text(
                          Languages.wallet.time,
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppDateTimeFormatter.display(
                            transaction.time,
                            locale: locale,
                            languages: AppLocale.current,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
