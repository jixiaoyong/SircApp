import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/constrained_content.dart';
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
      duration: const Duration(
        seconds: ForgetPwdState.verifyCodeDurationSecond,
      ),
    );

    _controller.addListener(() {
      final remain =
          ((1 - _controller.value) * ForgetPwdState.verifyCodeDurationSecond)
              .toInt();
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
    ref.listen<ForgetPwdState>(forgetPwdControllerProvider, (
      previous,
      next,
    ) async {
      if (previous?.isVerifyingCode != true && next.isVerifyingCode) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(Languages.loading),
            content: SizedBox(
              height: 50,
              width: 50,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (previous?.isVerifyingCode == true && !next.isVerifyingCode) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isVerifySuccess != next.isVerifySuccess &&
          next.isVerifySuccess == true) {
        final resetResult = await context.push<bool>(
          AppRoutes.SET_PWD,
          extra: next.userEmail,
        );
        if (true == resetResult && context.mounted) {
          context.pop(true);
        }
      }
    });

    final state = ref.watch(forgetPwdControllerProvider);
    final notifier = ref.read(forgetPwdControllerProvider.notifier);

    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isVerifyButtonEnabled =
        !state.isVerifyingCode && notifier.isEmailAndVerifyCodeValid();
    final isSendVerifyCodeBtnDisable = state.lastSendVerifyCodeTime > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.forgetPassword,
          style: TextStyle(color: colors.onSurface),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 520,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                Languages.enterEmailToResetPassword,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CommonTextFiled(
                  label: Languages.emailAddress,
                  enabled: !state.isVerifyingCode,
                  keyboardType: TextInputType.emailAddress,
                  errorText: state.userEmailError,
                  suffixIcon:
                      state.userEmail.isNotEmpty && state.userEmailError == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed:
                                  isSendVerifyCodeBtnDisable ||
                                      state.isVerifyingCode
                                  ? null
                                  : () {
                                      notifier.verifyEmail();
                                      _controller.forward();
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: colors.secondary,
                                minimumSize: const Size(44, 44),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: Text(
                                Languages.verify +
                                    (state.lastSendVerifyCodeTime > 0
                                        ? ' (${state.lastSendVerifyCodeTime}s)'
                                        : ''),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          Icons.email_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                  onChanged: notifier.setUserEmail,
                ),
              ),
              if (state.isWaitingForVerifyCode)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        Languages.pleaseEnterVerifyCode,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
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
                text: Languages.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
