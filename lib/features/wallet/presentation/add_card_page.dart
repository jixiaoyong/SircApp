import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

/// 添加银行卡页面，支持 3D 悬浮投影、手势交互倾斜与表单录入校验
class AddCardPage extends ConsumerWidget {
  const AddCardPage({super.key});

  static const String _defaultCardNumber = '**** **** **** ****';
  static const String _defaultOwnerName = 'YOUR NAME';
  static const String _defaultExpireDate = '00/00';
  static const String _defaultBankName = 'Visa Classic';
  static const String _defaultCardType = 'Visa';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(addCardControllerProvider);
    final controller = ref.read(addCardControllerProvider.notifier);
    final isButtonEnable = state.isUserInputValid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Card".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300.dp,
              child: Stack(
                children: [
                  FootlightsForBankCard(
                    screenWidth: CommonData.realScreenWidth,
                  ),
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
                          expirationDate: state.expireDateString ?? _defaultExpireDate,
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
              padding:
                  EdgeInsets.symmetric(horizontal: 20.dp, vertical: 25.dp),
              child: Column(
                children: [
                  CommonTextFiled(
                    label: "Name On Card".tr,
                    onChanged: (value) {
                      controller.setOwnerName(value);
                    },
                    errorText: state.ownerNameError,
                    maxLength: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.dp),
                    child: CommonTextFiled(
                      label: "Card Number".tr,
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
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20.dp),
                          child: Text(
                            "${"Expire Date".tr}:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Colors.blue,
                          ),
                          child: Builder(
                            builder: (innerBuildContext) {
                              return GestureDetector(
                                onTap: () async {
                                  final nowDate = DateTime.now();
                                  final selectedDate = await showMonthPicker(
                                    context: innerBuildContext,
                                    initialDate: state.expireDate ?? nowDate,
                                    firstDate: DateTime.utc(nowDate.year - 1),
                                    lastDate: DateTime.utc(nowDate.year + 20),
                                    monthPickerDialogSettings:
                                        MonthPickerDialogSettings(
                                      dialogSettings: PickerDialogSettings(
                                        locale: AppLocale.currentLocale,
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
                                    borderRadius: BorderRadius.circular(10.dp),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text(
                                    state.expireDateString ?? "00/00",
                                    style: TextStyle(
                                      fontSize: 18.sp,
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
                    padding: EdgeInsets.only(top: 20.dp, bottom: 20.dp),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20.dp),
                          child: Text(
                            "${"CVV".tr}:",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
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
                    text: "Add Card".tr,
                    isButtonEnabled: isButtonEnable && !state.isSubmitting,
                    onTap: () async {
                      final success = await controller.addCard();
                      if (success && context.mounted) {
                        Toast.show("Add Card Succeed");
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
