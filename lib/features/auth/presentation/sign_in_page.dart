import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    show LayoutScope, ResponsiveQuery;
import 'package:sirc/widgets/constrained_content.dart';
import 'package:sirc/widgets/password_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/routes/app_routes.dart';

/*
* @description: Sign In Page (Refactored to Riverpod & Clean Architecture)
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController nameTextFieldController = TextEditingController();
  final TextEditingController pwdTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(signInControllerProvider.notifier);
      await notifier.initPresetAccount();
      final currentState = ref.read(signInControllerProvider);
      nameTextFieldController.text = currentState.userName;
      pwdTextFieldController.text = currentState.userPwd;
    });
  }

  @override
  void dispose() {
    nameTextFieldController.dispose();
    pwdTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听加载与登录结果副作用
    ref.listen<SignInState>(signInControllerProvider, (previous, next) {
      if (previous?.isLoading != true && next.isLoading) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(Languages.loading),
            content: SizedBox(
              height: 50.toDouble(),
              width: 50.toDouble(),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (previous?.isLoading == true && !next.isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isLoginSuccess != next.isLoginSuccess &&
          next.isLoginSuccess != null) {
        if (next.isLoginSuccess == true) {
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go(AppRoutes.MAIN);
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(Languages.loginFailed),
              content: SizedBox(
                height: 80.toDouble(),
                child: Center(
                  child: Icon(
                    Icons.error_outline_outlined,
                    color: Colors.red,
                    size: 80.toDouble(),
                  ),
                ),
              ),
            ),
          );
        }
      }
    });

    final state = ref.watch(signInControllerProvider);
    final notifier = ref.read(signInControllerProvider.notifier);

    final isLoginInProgress = state.isLoading;
    final isButtonEnabled = !isLoginInProgress && state.isUserInputValid;

    final iconSize = 24.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.signIn,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: LayoutScope(
        child: Builder(
          builder: (localContext) => SingleChildScrollView(
            child: ConstrainedContent(
              maxWidth: ResponsiveQuery.of(localContext).width
                  .clamp(0.0, 520.0),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CommonTextFiled(
                    controller: nameTextFieldController,
                    label: Languages.username,
                    errorText: state.userNameError,
                    suffixIcon: const Icon(Icons.person_outline),
                    onChanged: notifier.setUserName,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: PasswordTextField(
                      controller: pwdTextFieldController,
                      label: Languages.password,
                      errorText: state.userPwdError,
                      onChanged: notifier.setUserPwd,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await context.push<bool>(
                            AppRoutes.FORGET_PWD,
                          );
                          if (true == result && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Languages.setPasswordSucceed,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(Languages.pleaseLoginWithNewPassword),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          Languages.forgetPasswords,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            height: 3,
                            fontSize: 12.toDouble(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: isButtonEnabled ? notifier.login : null,
                        child: Text(Languages.login),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      Languages.orSignInWith,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50.toDouble(),
                    width: double.infinity,
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = state.socialList[index];
                          return GestureDetector(
                            onTap: () {
                              notifier.loginWith(item);
                            },
                            child: Container(
                              height: 50.toDouble(),
                              width: 50.toDouble(),
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.toDouble(),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  8.toDouble(),
                                ),
                                border: Border.all(color: item.$2, width: 1),
                              ),
                              child: Center(
                                child: Icon(
                                  item.$1,
                                  color: item.$2,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: state.socialList.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      text: Languages.dontHaveAccount,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.toDouble(),
                      ),
                      children: [
                        TextSpan(
                          text: " ${Languages.signUp}",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 12.toDouble(),
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push(AppRoutes.SIGN_UP),
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
