import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

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

      if (previous?.isRegisterSuccess != next.isRegisterSuccess && next.isRegisterSuccess != null) {
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
                  Text(Languages.registerSucceed, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    final screenHeight = MediaQuery.of(context).size.height;
    final isLoginInProgress = state.isLoading;
    final isButtonEnabled = !isLoginInProgress && state.isUserInputValid;
    final marginBetweenFields = screenHeight * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.signUp,
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
        margin: EdgeInsets.fromLTRB(16.dp, 16.dp, 16.dp, 0),
        padding: EdgeInsets.fromLTRB(20.dp, 20.dp, 20.dp, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 10.dp,
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
                  decoration: InputDecoration(
                    hintText: Languages.username,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.username,
                    errorText: state.userNameError,
                    suffixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (value) {
                    notifier.setUserName(value);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: marginBetweenFields),
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
                    hintText: Languages.emailAddress,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.emailAddress,
                    errorText: state.userEmailError,
                    suffixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (value) {
                    notifier.setUserEmail(value);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: marginBetweenFields),
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
                    hintText: Languages.password,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.password,
                    errorText: state.userPwdError,
                    suffixIcon: const Icon(
                      Icons.lock_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    notifier.setUserPwd(value);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: marginBetweenFields),
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
                    hintText: Languages.confirmPassword,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black12, width: 0),
                    ),
                    labelText: Languages.confirmPassword,
                    errorText: state.userConfirmPwdError,
                    suffixIcon: const Icon(
                      Icons.lock_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    notifier.setUserConfirmPwd(value);
                  },
                ),
              ),
              GestureDetector(
                onTap: !isButtonEnabled ? null : () => notifier.register(),
                child: Container(
                  height: 50.dp,
                  margin: EdgeInsets.only(top: 30.dp, bottom: 20.dp),
                  decoration: !isButtonEnabled
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8.dp),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey, width: 1),
                        )
                      : BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400.withValues(alpha: 0.7),
                              Colors.deepPurpleAccent.shade400.withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.dp),
                        ),
                  child: Center(
                    child: Text(
                      Languages.register,
                      style: TextStyle(
                        color: !isButtonEnabled ? Colors.grey : Colors.white,
                        fontSize: 16.dp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              TitleText(text: Languages.orSignUpWith),
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
                            child: Center(
                              child: Icon(
                                item.$1,
                                color: item.$2,
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
                padding: EdgeInsets.only(top: 20.dp, bottom: 50.dp),
                child: RichText(
                  text: TextSpan(
                    text: Languages.haveAccount,
                    style: TextStyle(color: Colors.black, fontSize: 12.dp),
                    children: [
                      TextSpan(
                        text: " ${Languages.signIn}",
                        style: TextStyle(
                          color: Colors.purple,
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
