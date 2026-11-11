import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/constrained_content.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

/// 添加银行卡页面，支持 3D 悬浮投影、手势交互倾斜与表单录入校验
class AddCardPage extends ConsumerStatefulWidget {
  const AddCardPage({super.key, this.onBack, this.card});

  final VoidCallback? onBack;
  final BankCard? card;

  @override
  ConsumerState<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends ConsumerState<AddCardPage> {
  final _owner = TextEditingController();
  final _number = TextEditingController();
  VoidCallback? get onBack => widget.onBack;

  @override
  void initState() {
    super.initState();
    _owner.text = widget.card?.ownerName ?? '';
    _number.text = widget.card?.cardNumber ?? '';
    Future.microtask(() {
      if (!mounted) return;
      ref.read(addCardControllerProvider.notifier).startEditing(widget.card);
      _owner.text = ref.read(addCardControllerProvider).ownerName;
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
    final state = ref.watch(addCardControllerProvider);
    final controller = ref.read(addCardControllerProvider.notifier);
    final isButtonEnable = state.isUserInputValid;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final title = widget.card == null
        ? Languages.addCard
        : (zh ? '编辑卡片' : 'Edit card');

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
          child: Column(
            children: [
              SizedBox(
                height: 300.dp,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(35.dp),
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
                            height: 200.dp,
                            width: 200.dp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.dp,
                  vertical: 25.dp,
                ),
                child: Column(
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
                      padding: EdgeInsets.only(top: 20.dp),
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
                      padding: EdgeInsets.only(top: 20.dp),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "${Languages.expireDate}:",
                            style: TextStyle(
                              fontSize: 16.sp,
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
                                    final nowDate = DateTime.now();
                                    final firstDate = DateTime(
                                      nowDate.year - 1,
                                    );
                                    final lastDate = DateTime(
                                      nowDate.year + 20,
                                    );
                                    final initialDate =
                                        state.expireDate ?? nowDate;
                                    final selectedDate = await showMonthPicker(
                                      context: innerBuildContext,
                                      initialDate:
                                          initialDate.isBefore(firstDate)
                                          ? firstDate
                                          : initialDate.isAfter(lastDate)
                                          ? lastDate
                                          : initialDate,
                                      firstDate: DateTime.utc(nowDate.year - 1),
                                      lastDate: DateTime.utc(nowDate.year + 20),
                                      monthPickerDialogSettings:
                                          MonthPickerDialogSettings(
                                            dialogSettings:
                                                PickerDialogSettings(
                                                  locale:
                                                      AppLocale.currentLocale,
                                                ),
                                          ),
                                    );
                                    if (selectedDate != null) {
                                      controller.setExpireDate(selectedDate);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.dp,
                                      horizontal: 10.dp,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        14.dp,
                                      ),
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
                                      style: TextStyle(fontSize: 18.sp),
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
                      padding: EdgeInsets.only(top: 20.dp, bottom: 20.dp),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 20.dp),
                            child: Text(
                              "${Languages.cvv}:",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: VerifyCodeWidget(
                              onChanged: (value) {
                                controller.setCvv(value);
                              },
                              verifyCodeCount: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CommonTextButton(
                      text: widget.card == null ? title : (zh ? '保存' : 'Save'),
                      isButtonEnabled: isButtonEnable && !state.isSubmitting,
                      onTap: () async {
                        final success = await controller.addCard();
                        if (success && context.mounted) {
                          Toast.show(zh ? '卡片已保存' : 'Card saved');
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
    );
  }
}
