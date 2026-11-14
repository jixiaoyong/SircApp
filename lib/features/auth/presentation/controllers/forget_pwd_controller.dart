import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

part 'forget_pwd_controller.g.dart';

class ForgetPwdState {
  final String userEmail;
  final String verifyCode;
  final String? userEmailError;
  final bool isVerifyingCode;
  final int lastSendVerifyCodeTime;
  final bool isWaitingForVerifyCode;
  final bool? isVerifySuccess;

  static const int verifyCodeLength = 6;
  static const int verifyCodeDurationSecond = 60;

  const ForgetPwdState({
    this.userEmail = "",
    this.verifyCode = "",
    this.userEmailError,
    this.isVerifyingCode = false,
    this.lastSendVerifyCodeTime = 0,
    this.isWaitingForVerifyCode = false,
    this.isVerifySuccess,
  });

  ForgetPwdState copyWith({
    String? userEmail,
    String? verifyCode,
    String? Function()? userEmailError,
    bool? isVerifyingCode,
    int? lastSendVerifyCodeTime,
    bool? isWaitingForVerifyCode,
    bool? Function()? isVerifySuccess,
  }) {
    return ForgetPwdState(
      userEmail: userEmail ?? this.userEmail,
      verifyCode: verifyCode ?? this.verifyCode,
      userEmailError: userEmailError != null
          ? userEmailError()
          : this.userEmailError,
      isVerifyingCode: isVerifyingCode ?? this.isVerifyingCode,
      lastSendVerifyCodeTime:
          lastSendVerifyCodeTime ?? this.lastSendVerifyCodeTime,
      isWaitingForVerifyCode:
          isWaitingForVerifyCode ?? this.isWaitingForVerifyCode,
      isVerifySuccess: isVerifySuccess != null
          ? isVerifySuccess()
          : this.isVerifySuccess,
    );
  }
}

@riverpod
class ForgetPwdController extends _$ForgetPwdController {
  @override
  ForgetPwdState build() => const ForgetPwdState();

  void setUserEmail(String value) {
    final error = UsernamePwdUtils.checkUserEmail(value);
    state = state.copyWith(userEmail: value, userEmailError: () => error);
  }

  void setVerifyCode(String value) {
    state = state.copyWith(verifyCode: value);
  }

  void updateCountdown(int seconds) {
    state = state.copyWith(lastSendVerifyCodeTime: seconds);
  }

  void verifyEmail() {
    state = state.copyWith(isWaitingForVerifyCode: true);
  }

  bool isEmailAndVerifyCodeValid() {
    return state.userEmailError == null &&
        state.userEmail.isNotEmpty &&
        state.verifyCode.length == ForgetPwdState.verifyCodeLength;
  }

  Future<void> verifyEmailAndResetPwd({Duration? mockDelay}) async {
    if (!isEmailAndVerifyCodeValid()) return;

    state = state.copyWith(isVerifyingCode: true, isVerifySuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.verifyResetCode(
      state.userEmail,
      state.verifyCode,
      mockDelay: mockDelay,
    );

    state = state.copyWith(
      isVerifyingCode: false,
      isVerifySuccess: () => success,
    );
  }

  void resetVerifyStatus() {
    state = state.copyWith(isVerifySuccess: () => null);
  }
}

typedef ForgetPwdNotifier = ForgetPwdController;
