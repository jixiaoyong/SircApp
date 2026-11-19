import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';

part 'password_controller.g.dart';

class PasswordState {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool isOldPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? errorMessage;
  final bool isLoading;
  final bool? isSuccess;

  const PasswordState({
    this.oldPassword = "",
    this.newPassword = "",
    this.confirmPassword = "",
    this.isOldPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.errorMessage,
    this.isLoading = false,
    this.isSuccess,
  });

  PasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? isOldPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? Function()? errorMessage,
    bool? isLoading,
    bool? Function()? isSuccess,
  }) {
    return PasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isOldPasswordVisible: isOldPasswordVisible ?? this.isOldPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess != null ? isSuccess() : this.isSuccess,
    );
  }
}

@riverpod
class PasswordController extends _$PasswordController {
  @override
  PasswordState build() => const PasswordState();

  void setOldPassword(String value) {
    state = state.copyWith(
      oldPassword: value,
      errorMessage: () => _validatePasswords(oldPwd: value),
    );
  }

  void setNewPassword(String value) {
    state = state.copyWith(
      newPassword: value,
      errorMessage: () => _validatePasswords(newPwd: value),
    );
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      errorMessage: () => _validatePasswords(confirmPwd: value),
    );
  }

  void setOldPasswordVisible(bool visible) {
    state = state.copyWith(isOldPasswordVisible: visible);
  }

  void setNewPasswordVisible(bool visible) {
    state = state.copyWith(isNewPasswordVisible: visible);
  }

  void setConfirmPasswordVisible(bool visible) {
    state = state.copyWith(isConfirmPasswordVisible: visible);
  }

  String? _validatePasswords({
    String? oldPwd,
    String? newPwd,
    String? confirmPwd,
  }) {
    final oldP = oldPwd ?? state.oldPassword;
    final newP = newPwd ?? state.newPassword;
    final confirmP = confirmPwd ?? state.confirmPassword;

    if (oldP.isEmpty) {
      return Languages.pleaseInputCurrentPassword;
    }
    if (newP.isEmpty) {
      return Languages.pleaseInputNewPassword;
    }
    if (confirmP.isEmpty) {
      return Languages.pleaseInputConfirmPassword;
    }
    if (newP != confirmP) {
      return Languages.passwordInconsistent;
    }
    if (newP.length < 6 || confirmP.length < 6) {
      return Languages.passwordMinLengthPrompt;
    }
    return null;
  }

  Future<void> changePassword({Duration? mockDelay}) async {
    final error = _validatePasswords();
    if (error != null) {
      state = state.copyWith(errorMessage: () => error);
      return;
    }

    state = state.copyWith(isLoading: true, isSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.changePassword(
      state.oldPassword,
      state.newPassword,
      mockDelay: mockDelay,
    );

    state = state.copyWith(isLoading: false, isSuccess: () => success);
  }

  void resetSuccessStatus() {
    state = state.copyWith(isSuccess: () => null);
  }
}

typedef PasswordNotifier = PasswordController;
