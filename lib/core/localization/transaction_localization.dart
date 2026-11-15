import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/l10n/impl/en/common_en.dart';
import 'package:sirc/l10n/impl/zh/common_zh.dart';

import 'app_locale.dart';

/// 展示时仅重新解析已知名称占位文案，不翻译真实交易名称或业务时间。
extension TransactionLocalization on Transaction {
  /// 本地化名称占位符，保留原始业务时间供统一日期格式化器处理。
  Transaction get localizedPlaceholders => copyWith(
    moneyActionName:
        {
          const CommonEn().something,
          const CommonZh().something,
        }.contains(moneyActionName)
        ? Languages.something
        : moneyActionName,
  );
}
