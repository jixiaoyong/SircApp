import 'package:flutter/material.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class BankCardWidget extends StatelessWidget {
  final String cardNumber;
  final String bankName;
  final String ownerName;
  final String expirationDate;
  final String? cardType;
  final double? height;
  final double? width;

  BankCardWidget({
    super.key,
    required this.bankName,
    required String cardNumber,
    required this.ownerName,
    required this.expirationDate,
    this.cardType,
    this.height,
    this.width,
  }) : cardNumber = _formatCardNumber(cardNumber);

  static String _formatCardNumber(String raw) {
    final clean = raw.replaceAll(' ', '').trim();
    return clean.replaceAllMapped(RegExp(r'([\s\S]{4})'), (match) {
      return '${match.group(1)} ';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 方案 C：对应 design/bank-card-options.html 的 .card.c。
    // 虹彩只占 2dp 边缘，卡面使用不透明深底，不叠加玻璃或外围彩光。
    return DecoratedBox(
      key: const ValueKey('bank-card-iridescent-edge'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.dp),
        gradient: const LinearGradient(
          begin: Alignment(-0.819152, -0.573576),
          end: Alignment(0.819152, 0.573576),
          colors: [
            Color(0xFF91AAB0),
            Color(0xFFA99AA9),
            Color(0xFF697F89),
            Color(0xFFB4B39B),
          ],
          stops: [0, .32, .65, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2.dp),
        child: Container(
          height: (height ?? 200.dp) - 4.dp,
          width: width == null ? null : width! - 4.dp,
          padding: EdgeInsets.symmetric(horizontal: 14.dp, vertical: 12.dp),
          key: const ValueKey('bank-card-dark-surface'),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.766044, -0.642788),
              end: Alignment(0.766044, 0.642788),
              colors: [Color(0xFF2E363B), Color(0xFF252B30), Color(0xFF2B3034)],
              stops: [0, .6, 1],
            ),
            borderRadius: BorderRadius.circular(18.dp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.dp),
                child: Image.asset(
                  A.assets_imgs_bank_chip,
                  height: 32.dp,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.dp),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    cardNumber,
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.dp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              ownerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.dp),
                          Text(
                            expirationDate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.dp),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          cardType ?? Languages.visa,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
