import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/l10n/impl/en/common_en.dart';
import 'package:sirc/l10n/impl/en/home_en.dart';
import 'package:sirc/l10n/impl/zh/common_zh.dart';
import 'package:sirc/l10n/impl/zh/home_zh.dart';

import 'app_locale.dart';

/// Mock 流水缓存的是已翻译字符串；展示时仅重新解析已知占位文案，
/// 不翻译真实交易名称，也不将相对时间文案当作时间戳或进行时区换算。
extension TransactionLocalization on Transaction {
  Transaction get localizedPlaceholders => copyWith(
        moneyActionName: {
          const CommonEn().something,
          const CommonZh().something,
          '某些东西', // 兼容已缓存的旧中文占位文案。
        }.contains(moneyActionName)
            ? Languages.something
            : moneyActionName,
        time: {
          const HomeEn().justNow,
          const HomeZh().justNow,
        }.contains(time)
            ? Languages.justNow
            : time,
      );
}
