import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/constrained_content.dart';
import 'package:sirc/widgets/password_text_field.dart';

/*
* @description: Set Password Page (Refactored to Riverpod & Clean Architecture)
* need pass the userName with key: [CommonKeys.USER_NAME]
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class SetPwdPage extends ConsumerStatefulWidget {
  final String? initialUserName;

  const SetPwdPage({super.key, this.initialUserName});

  @override
  ConsumerState<SetPwdPage> createState() => _SetPwdPageState();
}

class _SetPwdPageState extends ConsumerState<SetPwdPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? userName = widget.initialUserName;
      if (userName == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args.containsKey(CommonKeys.USER_NAME)) {
          userName = args[CommonKeys.USER_NAME] as String?;
        }
      }
      if (userName != null) {
        ref.read(setPwdControllerProvider.notifier).setUserName(userName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听重置结果副作用
    ref.listen<SetPwdState>(setPwdControllerProvider, (previous, next) {
      if (previous?.isWaitSetPwdResult != true && next.isWaitSetPwdResult) {
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
      } else if (previous?.isWaitSetPwdResult == true &&
          !next.isWaitSetPwdResult) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isSuccess != next.isSuccess && next.isSuccess == true) {
        Navigator.of(context).pop(true);
      }
    });

    final state = ref.watch(setPwdControllerProvider);
    final notifier = ref.read(setPwdControllerProvider.notifier);
    const marginBetweenFields = 20.0;
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.addNewPassword,
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
              PasswordTextField(
                label: Languages.password,
                errorText: state.userPwdError,
                isNewPassword: true,
                enabled: !state.isWaitSetPwdResult,
                onChanged: notifier.setUserPwd,
              ),
              Padding(
                padding: const EdgeInsets.only(top: marginBetweenFields),
                child: PasswordTextField(
                  label: Languages.confirmPassword,
                  errorText: state.userConfirmPwdError,
                  isNewPassword: true,
                  enabled: !state.isWaitSetPwdResult,
                  onChanged: notifier.setUserConfirmPwd,
                ),
              ),
              CommonTextButton(
                isButtonEnabled:
                    !state.isWaitSetPwdResult && state.isUserInputValid,
                onTap: () {
                  notifier.resetPwd();
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
