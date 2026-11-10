import 'package:flutter/material.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/// Read-only transaction detail; the source-provided Hero identity is preserved.
class HistoryDetailsPage extends StatelessWidget {
  const HistoryDetailsPage({
    super.key,
    required this.data,
    required this.heroTag,
  });
  final Transaction data;
  final String heroTag;
  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final amountColor = (data.moneyAmount ?? 0) < 0
        ? AppColors.expense(context)
        : AppColors.income(context);
    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(title: zh ? '交易详情' : 'Details'),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: NetworkWebImage(
                        data.userIcon ?? '',
                        size: const Size.square(72),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.moneyActionName ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.moneyAmount.toFormatedMoneyStr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.time ?? '',
                    style: TextStyle(color: AppColors.muted(context)),
                  ),
                  const SizedBox(height: 32),
                  WalletPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zh ? '交易类型' : 'Transaction type',
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(data.moneyActionName ?? ''),
                        const Divider(height: 32),
                        Text(
                          zh ? '金额' : 'Amount',
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.moneyAmount.toFormatedMoneyStr,
                          style: TextStyle(color: amountColor),
                        ),
                        const Divider(height: 32),
                        Text(
                          zh ? '时间' : 'Time',
                          style: TextStyle(color: AppColors.muted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(data.time ?? ''),
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
