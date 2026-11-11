import 'package:sirc/core/localization/app_locale.dart';

/// 仅格式化已知卡组织的展示文案，不改写卡片原始数据或银行名称。
String cardBrandLabel(String? cardType) =>
    switch (cardType?.trim().toLowerCase()) {
      null || 'visa' => Languages.wallet.visa,
      'mastercard' => Languages.wallet.masterCard,
      _ => cardType!,
    };
