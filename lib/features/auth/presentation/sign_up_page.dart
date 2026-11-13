import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    show LayoutScope;
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
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
              height: 50,
              width: 50,
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
          context.go(AppRoutes.SIGN_IN);
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
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.error_outline_outlined,
                    color: Theme.of(context).colorScheme.error,
                    size: 80,
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

    final colors = Theme.of(context).colorScheme;
    final ink = colors.onSurface;
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: LayoutScope(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
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
                          padding: const EdgeInsets.only(
                            top: marginBetweenFields,
                          ),
                          child: SignUpField(
                            label: Languages.emailAddress,
                            errorText: state.userEmailError,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoginInProgress,
                            onChanged: notifier.setUserEmail,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: marginBetweenFields,
                          ),
                          child: SignUpField(
                            label: Languages.password,
                            errorText: state.userPwdError,
                            password: true,
                            enabled: !isLoginInProgress,
                            onChanged: notifier.setUserPwd,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: marginBetweenFields,
                          ),
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
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: isButtonEnabled
                                  ? notifier.register
                                  : null,
                              child: Text(Languages.register),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                ),
                                child: Text(
                                  Languages.orSignUpWith,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
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
                                      height: 50,
                                      width: 50,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: colors.outline,
                                          width: 1.25,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          item.$1,
                                          color: ink,
                                          size: 20,
                                        ),
                                      ),
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
                          padding: const EdgeInsets.only(top: 20),
                          child: RichText(
                            text: TextSpan(
                              text: Languages.haveAccount,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: " ${Languages.signIn}",
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.go(AppRoutes.SIGN_IN),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
