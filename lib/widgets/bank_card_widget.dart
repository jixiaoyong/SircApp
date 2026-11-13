import 'package:material_ui/material_ui.dart';
import 'package:sirc/features/wallet/presentation/card_brand_label.dart';
import 'package:sirc/gen_a/A.dart';

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
  final bool isSelected;
  final double? selectionHighlightProgress;

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
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: const Alignment(-0.819152, -0.573576),
          end: const Alignment(0.819152, 0.573576),
          colors: isSelected
              ? const [
                  Color(0xFFB0C7CC),
                  Color(0xFFC6B7C6),
                  Color(0xFF8CA2AC),
                  Color(0xFFCFCEB5),
                ]
              : const [
                  Color(0xFF91AAB0),
                  Color(0xFFA99AA9),
                  Color(0xFF697F89),
                  Color(0xFFB4B39B),
                ],
          stops: const [0, .32, .65, 1],
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
        padding: EdgeInsets.all(2),
        child: Container(
          height: (height ?? 200) - 4,
          width: width == null ? null : width! - 4,
          key: const ValueKey('bank-card-dark-surface'),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.766044, -0.642788),
              end: Alignment(0.766044, 0.642788),
              colors: [Color(0xFF2E363B), Color(0xFF252B30), Color(0xFF2B3034)],
              stops: [0, .6, 1],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: CustomPaint(
            painter: _CardSelectionHighlightPainter(
              progress: selectionHighlightProgress,
              radius: 18,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bankName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Image.asset(
                      A.assets_imgs_bank_chip,
                      height: 32,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cardNumber,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
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
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                expirationDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              cardBrandLabel(cardType),
                              style: TextStyle(
                                fontSize: 18,
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
        ),
      ),
    );
  }
}

// Paint beneath the content: the narrow reflection never washes out card text.
class _CardSelectionHighlightPainter extends CustomPainter {
  const _CardSelectionHighlightPainter({
    required this.progress,
    required this.radius,
  });

  final double? progress;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final value = progress;
    if (value == null || value <= 0 || value >= 1) return;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
    final x = -size.width * .25 + size.width * 1.5 * value;
    final band = Rect.fromLTWH(
      x,
      -size.height,
      size.width * .14,
      size.height * 3,
    );
    final fade = 1 - (2 * value - 1).abs();
    canvas.skew(-.18, 0);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .12 * fade),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CardSelectionHighlightPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.radius != radius;
}
