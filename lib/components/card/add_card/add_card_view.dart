import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sirc/components/card/add_card/add_card_state.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

import 'add_card_logic.dart';

/*
* @description: add credit card page
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class AddCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(AddCardLogic());
    final state = Get.find<AddCardLogic>().state;

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
        child: Obx(() {
          final isButtonEnable = logic.isUserInputValid();
          return Column(
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
                          logic.onBankCardPanUpdate(details.delta);
                        },
                        onVerticalDragEnd: (details) {
                          logic.onBankCardPanUpdate(null);
                        },
                        child: Transform.rotate(
                          angle: state.cardRotateAngle.value,
                          child: BankCardWidget(
                            bankName: state.bankName.value.isEmpty
                                ? AddCardState.defaultCard.bankName
                                : state.bankName.value,
                            cardNumber: state.cardNumber.value.isEmpty
                                ? AddCardState.defaultCard.cardNumber
                                : state.cardNumber.value,
                            ownerName: state.ownerName.value.isEmpty
                                ? AddCardState.defaultCard.ownerName
                                : state.ownerName.value,
                            expirationDate: state.expireDateString.value ??
                                AddCardState.defaultCard.expirationDate,
                            cardType: state.cardType.value.isEmpty
                                ? AddCardState.defaultCard.cardType
                                : state.cardType.value,
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
                        logic.setOwnerName(value);
                      },
                      errorText: state.ownerNameError.value,
                      maxLength: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.dp),
                      child: CommonTextFiled(
                        label: "Card Number".tr,
                        onChanged: (value) {
                          logic.setCardNumber(value);
                        },
                        errorText: state.cardNumberError.value,
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
                            // Notice: the change of theme will not affect in
                            // this widget, MUST make sure your widget is child
                            // of this 'child' widget
                            child: Builder(
                              builder: (innerBuildContext) {
                                // here we can get the theme with innerBuildContext
                                return GestureDetector(
                                    onTap: () async {
                                      // set the range of date between last year and next 20 year
                                      final nowDate = DateTime.now();

                                      final selectedDate =
                                          await showMonthPicker(
                                              context: innerBuildContext,
                                              initialDate:
                                                  state.expireDate ?? nowDate,
                                              firstDate: DateTime.utc(
                                                  nowDate.year - 1),
                                              lastDate: DateTime.utc(
                                                  nowDate.year + 20),
                                              locale: Get.locale);
                                      if (selectedDate != null) {
                                        logic.setExpireDate(selectedDate);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5.dp, horizontal: 10.dp),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.dp),
                                          border:
                                              Border.all(color: Colors.blue)),
                                      child: Text(
                                        state.expireDateString.value ?? "00/00",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ));
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
                                logic.setCvv(value);
                              },
                              verifyCodeCount: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CommonTextButton(
                      text: "Add Card".tr,
                      isButtonEnabled: isButtonEnable,
                      onTap: () {
                        logic.addCard();
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
