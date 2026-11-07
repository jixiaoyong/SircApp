import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

/*
* @description: Forget Password Page (Refactored to Riverpod & Clean Architecture)
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class ForgetPwdPage extends ConsumerStatefulWidget {
  const ForgetPwdPage({super.key});

  @override
  ConsumerState<ForgetPwdPage> createState() => _ForgetPwdPageState();
}

class _ForgetPwdPageState extends ConsumerState<ForgetPwdPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: ForgetPwdState.verifyCodeDurationSecond),
    );

    _controller.addListener(() {
      final remain =
          ((1 - _controller.value) * ForgetPwdState.verifyCodeDurationSecond).toInt();
      ref.read(forgetPwdControllerProvider.notifier).updateCountdown(remain);
      if (_controller.value == 1) {
        _controller.reset();
        ref.read(forgetPwdControllerProvider.notifier).updateCountdown(0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听验证状态与跳转副作用
    ref.listen<ForgetPwdState>(forgetPwdControllerProvider, (previous, next) async {
      if (previous?.isVerifyingCode != true && next.isVerifyingCode) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Loading...".tr),
            content: SizedBox(
              height: 50.dp,
              width: 50.dp,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (previous?.isVerifyingCode == true && !next.isVerifyingCode) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isVerifySuccess != next.isVerifySuccess && next.isVerifySuccess == true) {
        final resetResult = await Navigator.of(context).pushNamed(
          AppRoutes.SET_PWD,
          arguments: {CommonKeys.USER_NAME: next.userEmail},
        );
        if (true == resetResult && context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    });

    final state = ref.watch(forgetPwdControllerProvider);
    final notifier = ref.read(forgetPwdControllerProvider.notifier);

    final isVerifyButtonEnabled = notifier.isEmailAndVerifyCodeValid();
    final isSendVerifyCodeBtnDisable = state.lastSendVerifyCodeTime > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forget Password".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(20.dp),
        child: Column(
          children: [
            Text(
              "Enter your email address to reset your password".tr,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Container(
              margin: EdgeInsets.only(top: 50.dp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.dp),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  )
                ],
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Email Address".tr,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black12, width: 0),
                  ),
                  labelText: "Email Address".tr,
                  errorText: state.userEmailError,
                  suffixIcon: state.userEmail.isNotEmpty && state.userEmailError == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: isSendVerifyCodeBtnDisable
                                  ? null
                                  : () {
                                      notifier.verifyEmail();
                                      _controller.forward();
                                    },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.dp),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.dp,
                                  vertical: 5.dp,
                                ),
                                decoration: BoxDecoration(
                                  color: isSendVerifyCodeBtnDisable
                                      ? Colors.grey
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(20.dp),
                                ),
                                child: Text(
                                  "verify".tr +
                                      (state.lastSendVerifyCodeTime > 0
                                          ? ' (${state.lastSendVerifyCodeTime}s)'
                                          : ''),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                ),
                onChanged: (value) {
                  notifier.setUserEmail(value);
                },
              ),
            ),
            if (state.isWaitingForVerifyCode)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50.dp),
                    child: Text(
                      "Please enter the verify code we sent to your email:".tr,
                      style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.dp),
                    child: VerifyCodeWidget(
                      onChanged: (value) {
                        notifier.setVerifyCode(value);
                      },
                    ),
                  ),
                ],
              ),
            CommonTextButton(
              isButtonEnabled: isVerifyButtonEnabled,
              onTap: () {
                notifier.verifyEmailAndResetPwd();
              },
              text: "Submit".tr,
            ),
          ],
        ),
      ),
    );
  }
}
