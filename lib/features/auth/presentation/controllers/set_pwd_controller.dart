import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

part 'set_pwd_controller.g.dart';

class SetPwdState {
  final String userName;
  final String userPwd;
  final String userConfirmPwd;
  final String? userPwdError;
  final String? userConfirmPwdError;
  final bool isUserInputValid;
  final bool isWaitSetPwdResult;
  final bool? isSuccess;

  const SetPwdState({
    this.userName = "",
    this.userPwd = "",
    this.userConfirmPwd = "",
    this.userPwdError,
    this.userConfirmPwdError,
    this.isUserInputValid = false,
    this.isWaitSetPwdResult = false,
    this.isSuccess,
  });

  SetPwdState copyWith({
    String? userName,
    String? userPwd,
    String? userConfirmPwd,
    String? Function()? userPwdError,
    String? Function()? userConfirmPwdError,
    bool? isUserInputValid,
    bool? isWaitSetPwdResult,
    bool? Function()? isSuccess,
  }) {
    return SetPwdState(
      userName: userName ?? this.userName,
      userPwd: userPwd ?? this.userPwd,
      userConfirmPwd: userConfirmPwd ?? this.userConfirmPwd,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      userConfirmPwdError: userConfirmPwdError != null
          ? userConfirmPwdError()
          : this.userConfirmPwdError,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      isWaitSetPwdResult: isWaitSetPwdResult ?? this.isWaitSetPwdResult,
      isSuccess: isSuccess != null ? isSuccess() : this.isSuccess,
    );
  }
}

@riverpod
class SetPwdController extends _$SetPwdController {
  @override
  SetPwdState build() => const SetPwdState();

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void setUserPwd(String value) {
    final pwdError = UsernamePwdUtils.checkPassword(
      value,
      confirmPwd: state.userConfirmPwd,
    );
    final confirmError = UsernamePwdUtils.checkPassword(
      state.userConfirmPwd,
      confirmPwd: value,
    );
    final isValid =
        pwdError == null &&
        confirmError == null &&
        value.isNotEmpty &&
        state.userConfirmPwd.isNotEmpty &&
        value == state.userConfirmPwd;
    state = state.copyWith(
      userPwd: value,
      userPwdError: () => pwdError,
      userConfirmPwdError: () => confirmError,
      isUserInputValid: isValid,
    );
  }

  void setUserConfirmPwd(String value) {
    final confirmError = UsernamePwdUtils.checkPassword(
      value,
      confirmPwd: state.userPwd,
    );
    final pwdError = UsernamePwdUtils.checkPassword(
      state.userPwd,
      confirmPwd: value,
    );
    final isValid =
        pwdError == null &&
        confirmError == null &&
        state.userPwd.isNotEmpty &&
        value.isNotEmpty &&
        state.userPwd == value;
    state = state.copyWith(
      userConfirmPwd: value,
      userConfirmPwdError: () => confirmError,
      userPwdError: () => pwdError,
      isUserInputValid: isValid,
    );
  }

  bool isUserNameAndPwdValid() {
    return state.userPwdError == null &&
        state.userConfirmPwdError == null &&
        state.userPwd.isNotEmpty &&
        state.userConfirmPwd.isNotEmpty &&
        state.userPwd == state.userConfirmPwd;
  }

  Future<void> resetPwd({Duration? mockDelay}) async {
    if (!isUserNameAndPwdValid()) return;

    state = state.copyWith(isWaitSetPwdResult: true, isSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.resetPassword(
      state.userName,
      state.userPwd,
      mockDelay: mockDelay,
    );

    state = state.copyWith(isWaitSetPwdResult: false, isSuccess: () => success);
  }

  void resetSuccessStatus() {
    state = state.copyWith(isSuccess: () => null);
  }
}

typedef SetPwdNotifier = SetPwdController;
