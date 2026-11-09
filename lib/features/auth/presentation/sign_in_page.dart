import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/title_text.dart';

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
              height: 50.dp,
              width: 50.dp,
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
          Navigator.of(context).pop(true);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(Languages.loginFailed),
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

    final state = ref.watch(signInControllerProvider);
    final notifier = ref.read(signInControllerProvider.notifier);

    final isLoginInProgress = state.isLoading;
    final isButtonEnabled = !isLoginInProgress && state.isUserInputValid;

    final logicScreenHeight =
        MediaQuery.of(context).size.height - kToolbarHeight - 16.dp;
    final iconSize = 24.dp;

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.dp),
          padding: EdgeInsets.symmetric(vertical: 20.dp),
          child: Column(
            children: [
              Container(
                height: 0.15 * logicScreenHeight,
              ),
              Container(
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
                  controller: nameTextFieldController,
                  decoration: InputDecoration(
                    hintText: Languages.username,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.dp),
                      borderSide:
                          const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.username,
                    errorText: state.userNameError,
                    suffixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.redAccent,
                      size: iconSize,
                    ),
                  ),
                  onChanged: (value) {
                    notifier.setUserName(value);
                  },
                ),
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
                  controller: pwdTextFieldController,
                  decoration: InputDecoration(
                    hintText: Languages.password,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.dp),
                      borderSide:
                          const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.password,
                    errorText: state.userPwdError,
                    suffixIcon: Icon(
                      Icons.lock_outlined,
                      color: Colors.grey,
                      size: iconSize,
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    notifier.setUserPwd(value);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result =
                          await context.push<bool>(AppRoutes.FORGET_PWD);
                      if (true == result && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Languages.setPasswordSucceed,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
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
                        fontSize: 12.dp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              CommonTextButton(
                isButtonEnabled: isButtonEnabled,
                onTap: () {
                  notifier.login();
                },
                text: Languages.login,
              ),
              TitleText(text: Languages.orSignInWith),
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
                            notifier.loginWith(item);
                          },
                          child: Container(
                            height: 50.dp,
                            width: 50.dp,
                            margin: EdgeInsets.symmetric(horizontal: 10.dp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.dp),
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
                  ],
                ),
              ),
              Container(
                height: logicScreenHeight * 0.08,
              ),
              RichText(
                text: TextSpan(
                  text: Languages.dontHaveAccount,
                  style: TextStyle(color: Colors.black, fontSize: 12.dp),
                  children: [
                    TextSpan(
                      text: " ${Languages.signUp}",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12.dp,
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
    );
  }
}
