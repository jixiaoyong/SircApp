import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';
import 'package:sirc/widgets/password_text_field.dart';
import 'package:sirc/widgets/constrained_content.dart';

/*
* @description: Password Page (Refactored to Riverpod & Clean Architecture)
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class PasswordPage extends ConsumerWidget {
  const PasswordPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    ref.listen<PasswordState>(passwordControllerProvider, (previous, next) {
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

      if (previous?.isSuccess != next.isSuccess && next.isSuccess != null) {
        if (next.isSuccess == true) {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Languages.oldPasswordIncorrect),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    });

    final state = ref.watch(passwordControllerProvider);
    final notifier = ref.read(passwordControllerProvider.notifier);
    final isValidError = state.errorMessage;
    final isButtonEnabled = !state.isLoading && isValidError == null;
    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.changePassword,
        onBack: onBack,
      ),
      body: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 520,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PasswordTextField(
                enabled: !state.isLoading,
                label: Languages.oldPassword,
                isVisible: state.isOldPasswordVisible,
                onVisibilityChanged: notifier.setOldPasswordVisible,
                onChanged: notifier.setOldPassword,
              ),
              Container(height: 20.dp),
              PasswordTextField(
                enabled: !state.isLoading,
                label: Languages.newPassword,
                errorText: isValidError,
                isNewPassword: true,
                isVisible: state.isNewPasswordVisible,
                onVisibilityChanged: notifier.setNewPasswordVisible,
                onChanged: notifier.setNewPassword,
              ),
              Container(height: 20.dp),
              PasswordTextField(
                enabled: !state.isLoading,
                label: Languages.confirmPassword,
                errorText: isValidError,
                isNewPassword: true,
                isVisible: state.isConfirmPasswordVisible,
                onVisibilityChanged: notifier.setConfirmPasswordVisible,
                onChanged: notifier.setConfirmPassword,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: Size(0, 50.dp),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: !isButtonEnabled
                        ? null
                        : () {
                            notifier.changePassword();
                          },
                    child: Text(Languages.changePassword),
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
