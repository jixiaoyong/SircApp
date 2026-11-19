import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    hide SizeExtension;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/constrained_content.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

/// 卡片新增与编辑入口；自行查询待编辑卡片并处理加载与不存在状态。
class CardEditorPage extends ConsumerStatefulWidget {
  const CardEditorPage({super.key, this.onBack, this.editingId});

  final VoidCallback? onBack;
  final String? editingId;

  @override
  ConsumerState<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends ConsumerState<CardEditorPage> {
  final _owner = TextEditingController();
  final _number = TextEditingController();
  VoidCallback? get onBack => widget.onBack;

  bool _formInitialized = false;

  void _initializeForm(BankCard? card) {
    if (_formInitialized) return;
    _formInitialized = true;
    _owner.text = card?.ownerName ?? '';
    _number.text = card?.cardNumber ?? '';
    Future.microtask(() async {
      if (!mounted) return;
      final controller = ref.read(addCardControllerProvider.notifier);
      if (card != null) {
        controller.startEditing(card);
        _owner.text = ref.read(addCardControllerProvider).ownerName;
      } else {
        await controller.startAdding();
        if (!mounted) return;
        _owner.text = ref.read(addCardControllerProvider).ownerName;
      }
    });
  }

  @override
  void dispose() {
    _owner.dispose();
    _number.dispose();
    super.dispose();
  }

  static const String _defaultCardNumber = '**** **** **** ****';
  static const String _defaultOwnerName = 'YOUR NAME';
  static const String _defaultExpireDate = '00/00';
  static const String _defaultBankName = 'Visa Classic';
  static const String _defaultCardType = 'Visa';

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final wallet = ref.watch(walletControllerProvider);
    final editingId = widget.editingId;
    final card = wallet.cards.where((card) => card.id == editingId).firstOrNull;
    if (editingId != null && card == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(Languages.wallet.editCard),
          leading: onBack == null ? null : BackButton(onPressed: onBack),
        ),
        body: Center(
          child: Text(
            wallet.isLoading
                ? Languages.wallet.cardLoading
                : Languages.wallet.cardNotFound,
          ),
        ),
      );
    }
    _initializeForm(card);
    final state = ref.watch(addCardControllerProvider);
    final controller = ref.read(addCardControllerProvider.notifier);
    final isButtonEnable = state.isUserInputValid;
    final title = editingId == null
        ? Languages.addCard
        : Languages.wallet.editCard;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        leading: onBack == null ? null : BackButton(onPressed: onBack),
      ),
      body: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 520,
          child: LayoutScope(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(35),
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            controller.onBankCardPanUpdate(details.delta);
                          },
                          onVerticalDragEnd: (details) {
                            controller.onBankCardPanUpdate(null);
                          },
                          child: Transform.rotate(
                            angle: state.cardRotateAngle,
                            child: BankCardWidget(
                              bankName: state.bankName.isEmpty
                                  ? _defaultBankName
                                  : state.bankName,
                              cardNumber: state.cardNumber.isEmpty
                                  ? _defaultCardNumber
                                  : state.cardNumber,
                              ownerName: state.ownerName.isEmpty
                                  ? _defaultOwnerName
                                  : state.ownerName,
                              expirationDate:
                                  state.expireDateString ?? _defaultExpireDate,
                              cardType: state.cardType.isEmpty
                                  ? _defaultCardType
                                  : state.cardType,
                              height: 200,
                              width: 200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonTextFiled(
                        controller: _owner,
                        label: Languages.nameOnCard,
                        onChanged: (value) {
                          controller.setOwnerName(value);
                        },
                        errorText: state.ownerNameError,
                        maxLength: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CommonTextFiled(
                          controller: _number,
                          label: Languages.cardNumber,
                          onChanged: (value) {
                            controller.setCardNumber(value);
                          },
                          errorText: state.cardNumberError,
                          maxLength: 16,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 16,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "${Languages.expireDate}:",
                              style: TextStyle(
                                fontSize: 16.toDouble(),
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            Theme(
                              data: Theme.of(context),
                              child: Builder(
                                builder: (innerBuildContext) {
                                  return GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      final nowDate = DateTime.now();
                                      final firstDate = DateTime(
                                        nowDate.year - 1,
                                      );
                                      final lastDate = DateTime(
                                        nowDate.year + 20,
                                      );
                                      final initialDate =
                                          state.expireDate ?? nowDate;
                                      final selectedDate =
                                          await showMonthPicker(
                                            context: innerBuildContext,
                                            initialDate:
                                                initialDate.isBefore(firstDate)
                                                ? firstDate
                                                : initialDate.isAfter(lastDate)
                                                ? lastDate
                                                : initialDate,
                                            firstDate: DateTime.utc(
                                              nowDate.year - 1,
                                            ),
                                            lastDate: DateTime.utc(
                                              nowDate.year + 20,
                                            ),
                                            monthPickerDialogSettings:
                                                MonthPickerDialogSettings(
                                                  dialogSettings:
                                                      PickerDialogSettings(
                                                        locale: AppLocale
                                                            .currentLocale,
                                                      ),
                                                ),
                                          );
                                      if (selectedDate != null) {
                                        HapticFeedback.selectionClick();
                                        controller.setExpireDate(selectedDate);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                      child: Text(
                                        state.expireDateString ?? "00/00",
                                        style: TextStyle(
                                          fontSize: 18.toDouble(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                "${Languages.cvv}:",
                                style: TextStyle(
                                  fontSize: 16.toDouble(),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 220,
                                  ),
                                  child: VerifyCodeWidget(
                                    onChanged: (value) {
                                      controller.setCvv(value);
                                      if (value.length == 4) {
                                        HapticFeedback.lightImpact();
                                      }
                                    },
                                    verifyCodeCount: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CommonTextButton(
                        text: editingId == null
                            ? title
                            : Languages.wallet.saveCard,
                        isButtonEnabled: isButtonEnable && !state.isSubmitting,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final success = await controller.addCard();
                          if (success && context.mounted) {
                            Toast.show(Languages.wallet.cardSaved);
                            if (onBack != null) {
                              onBack!();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
