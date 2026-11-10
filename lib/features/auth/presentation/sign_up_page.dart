import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/features/auth/presentation/sign_up_field.dart';
import 'package:sirc/widgets/constrained_content.dart';

/*
* @description: Sign Up Page (Refactored to Riverpod & Clean Architecture)
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    // 监听加载与注册结果副作用
    ref.listen<SignUpState>(signUpControllerProvider, (previous, next) {
      if (previous?.isLoading != true && next.isLoading) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(Languages.loading),
            content: SizedBox(
              height: 50.dp,
              width: 50.dp,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (previous?.isLoading == true && !next.isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isRegisterSuccess != next.isRegisterSuccess &&
          next.isRegisterSuccess != null) {
        if (next.isRegisterSuccess == true) {
          // 成功回到 Sign In 页面
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Languages.registerSucceed,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(Languages.pleaseSignIn),
                ],
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(Languages.registerFailed),
              content: SizedBox(
                height: 80.dp,
                child: Center(
                  child: Icon(
                    Icons.error_outline_outlined,
                    color: Colors.red,
                    size: 80.dp,
                  ),
                ),
              ),
            ),
          );
        }
      }
    });

    final state = ref.watch(signUpControllerProvider);
    final notifier = ref.read(signUpControllerProvider.notifier);

    final isLoginInProgress = state.isLoading;
    final isButtonEnabled = !isLoginInProgress && state.isUserInputValid;
    const marginBetweenFields = 20.0;

    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF2F2F2) : const Color(0xFF26282B);
    final background = dark ? const Color(0xFF181818) : Colors.white;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(Languages.signUp, style: TextStyle(color: ink)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: ink),
      ),
      body: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 520,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignUpField(
                label: Languages.username,
                errorText: state.userNameError,
                icon: 'user',
                enabled: !isLoginInProgress,
                onChanged: notifier.setUserName,
              ),
              Padding(
                padding: const EdgeInsets.only(top: marginBetweenFields),
                child: SignUpField(
                  label: Languages.emailAddress,
                  errorText: state.userEmailError,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoginInProgress,
                  onChanged: notifier.setUserEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: marginBetweenFields),
                child: SignUpField(
                  label: Languages.password,
                  errorText: state.userPwdError,
                  password: true,
                  enabled: !isLoginInProgress,
                  onChanged: notifier.setUserPwd,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: marginBetweenFields),
                child: SignUpField(
                  label: Languages.confirmPassword,
                  errorText: state.userConfirmPwdError,
                  password: true,
                  enabled: !isLoginInProgress,
                  onChanged: notifier.setUserConfirmPwd,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: ink,
                      foregroundColor: background,
                      disabledBackgroundColor: dark
                          ? const Color(0xFF353535)
                          : const Color(0xFFE1E1E1),
                      disabledForegroundColor: dark
                          ? const Color(0xFFB3B3B3)
                          : const Color(0xFF666666),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: isButtonEnabled ? notifier.register : null,
                    child: Text(Languages.register),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: Text(
                  Languages.orSignUpWith,
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 50.dp,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final item = state.socialList[index];
                        return GestureDetector(
                          onTap: () {
                            notifier.logUpWith(item);
                          },
                          child: Container(
                            height: 50.dp,
                            width: 50.dp,
                            margin: EdgeInsets.symmetric(horizontal: 10.dp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.dp),
                              border: Border.all(color: item.$2, width: 1),
                            ),
                            child: Center(child: Icon(item.$1, color: item.$2)),
                          ),
                        );
                      },
                      itemCount: state.socialList.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.dp, bottom: 50.dp),
                child: RichText(
                  text: TextSpan(
                    text: Languages.haveAccount,
                    style: TextStyle(color: ink, fontSize: 12.dp),
                    children: [
                      TextSpan(
                        text: " ${Languages.signIn}",
                        style: TextStyle(
                          color: ink,
                          fontSize: 12.dp,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
