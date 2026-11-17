import 'package:flutter/material.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/card_brand_label.dart';

/// 共享的极简扁平银行卡，随当前亮暗主题切换不透明卡面。
class BankCardWidget extends StatelessWidget {
  final String cardNumber;
  final String bankName;
  final String ownerName;
  final String expirationDate;
  final String? cardType;
  final double? height;
  final double? width;
  final bool isSelected;

  /// 保留调用兼容性；扁平卡面不再根据进度绘制扫光。
  final double? selectionHighlightProgress;

  /// 使用真实业务字段构造卡面，[maskCardNumber] 默认关闭以保留编辑预览。
  /// [isSelected] 仅加强细边框；[selectionHighlightProgress] 不产生材质效果。
  /// [height]、[width] 沿用调用方尺寸，默认高度为 200。
  BankCardWidget({
    super.key,
    required this.bankName,
    required String cardNumber,
    required this.ownerName,
    required this.expirationDate,
    this.cardType,
    this.height,
    this.width,
    this.isSelected = false,
    this.selectionHighlightProgress,
    bool maskCardNumber = false,
  }) : cardNumber = _formatCardNumber(cardNumber, mask: maskCardNumber);

  /// 根据 [card] 构造完整卡号视图，尺寸和选中参数与默认构造一致。
  BankCardWidget.fromCard(
    BankCard card, {
    Key? key,
    double? height,
    double? width,
    bool isSelected = false,
    double? selectionHighlightProgress,
  }) : this(
         key: key,
         bankName: card.bankName,
         cardNumber: card.cardNumber,
         ownerName: card.ownerName,
         expirationDate: card.expirationDate,
         cardType: card.cardType,
         height: height,
         width: width,
         isSelected: isSelected,
         selectionHighlightProgress: selectionHighlightProgress,
       );

  static String _formatCardNumber(String raw, {bool mask = false}) {
    var clean = raw.replaceAll(RegExp(r'\s+'), '');
    if (mask && clean.length > 8) {
      clean = clean.replaceRange(4, clean.length - 4, '*' * (clean.length - 8));
    }
    return clean.replaceAllMapped(RegExp(r'([\s\S]{4})'), (match) {
      return '${match.group(1)} ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFEEF1F6) : const Color(0xFF232B36);
    final muted = dark ? const Color(0xFFB7C1CE) : const Color(0xFF596473);
    final edge = dark ? const Color(0xFF495361) : const Color(0xFFCBD2DA);
    final circuit = dark ? const Color(0xFF9CAABB) : const Color(0xFF7D8997);
    final clean = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final tail = clean.length > 4 ? clean.substring(clean.length - 4) : clean;
    return Container(
      key: const ValueKey('bank-card-flat-surface'),
      height: height ?? 200,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF252C35) : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? muted : edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bankName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '•• $tail',
                    key: const ValueKey('bank-card-tail'),
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                key: const ValueKey('bank-card-chip'),
                width: 32,
                height: 25,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF333E4B)
                      : const Color(0xFFE6EAEF),
                  border: Border.all(color: circuit),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 15,
                      decoration: BoxDecoration(
                        border: Border.all(color: circuit),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(height: 1, color: circuit),
                  ],
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              cardNumber,
              style: TextStyle(
                fontSize: 16,
                color: ink,
                fontFamily: 'monospace',
                letterSpacing: .1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 1,
            color: dark ? const Color(0xFF424C59) : const Color(0xFFDCE1E7),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: _field(
                  Languages.wallet.nameOnCard,
                  ownerName,
                  ink,
                  muted,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                flex: 2,
                child: _field(
                  Languages.wallet.expireDate,
                  expirationDate,
                  ink,
                  muted,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    cardBrandLabel(cardType),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value, Color ink, Color muted) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: muted),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ink),
      ),
    ],
  );
}
