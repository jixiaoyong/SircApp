import '../../keys/auth_keys.dart';

class AuthZh implements AuthLang {
  const AuthZh();

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get loginFailed => '登录失败';

  @override
  String get registerSucceed => '注册成功';

  @override
  String get registerFailed => '注册失败';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get oldPassword => '旧密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get changePassword => '修改密码';

  @override
  String get addNewPassword => '设置新密码';

  @override
  String get setPasswordSucceed => '设置密码成功';

  @override
  String get pleaseLoginWithNewPassword => '请使用您的新密码登录。';

  @override
  String get oldPasswordIncorrect => '原密码不正确或修改失败';

  @override
  String get passwordInconsistent => '两次输入的密码不一致';

  @override
  String get passwordNotSame => '密码不一样';

  @override
  String get passwordMinLengthPrompt => '密码长度不能小于6位';

  @override
  String get passwordLengthMin => '用户密码长度必须大于6';

  @override
  String get passwordLengthMax => '用户密码长度必须小于12';

  @override
  String get usernameLengthMin => '用户名长度必须大于3';

  @override
  String get usernameLengthMax => '用户名长度必须小于10';

  @override
  String get email => '电子邮件';

  @override
  String get emailAddress => '电子邮件';

  @override
  String get emailFormatNotCorrect => '电子邮件格式不正确';

  @override
  String get emailLengthMin => '用户电子邮件长度必须大于5';

  @override
  String get emailLengthMax => '用户电子邮件长度必须小于30';

  @override
  String get enterEmailToResetPassword => '输入您的电子邮件地址来重置您的密码';

  @override
  String get forgetPassword => '忘记密码';

  @override
  String get forgetPasswords => '忘记密码？';

  @override
  String get forgotPin => '忘记密码';

  @override
  String get forgotPinDetail => '不用担心PIN码\n只需致电银行即可更改PIN码。';

  @override
  String get dontSharePassword => '不要分享密码';

  @override
  String get dontSharePasswordDetail => '使用字母、数字和特殊字符的强组合来设置密码。';

  @override
  String get manageAccount => '管理账户';

  @override
  String get manageAccountDetail => '银行账户保持交易活跃并定期更改密码更安全。';

  @override
  String get orSignInWith => '或通过下述方式登录';

  @override
  String get orSignUpWith => '或通过下述方式注册';

  @override
  String get haveAccount => '我已经有一个帐户';

  @override
  String get dontHaveAccount => '我没有账户';

  @override
  String get pleaseSignIn => '请登录';

  @override
  String get pleaseEnterVerifyCode => '请输入我们发送到您邮箱的验证码：';

  @override
  String get verify => '获取验证码';

  @override
  String get pleaseInputCurrentPassword => '请先输入现有密码';

  @override
  String get pleaseInputNewPassword => '请输入新密码';

  @override
  String get pleaseInputConfirmPassword => '请输入确认新密码';

  @override
  String get fingerprintLogin => '指纹登录';

  @override
  String get phoneNumber => '电话号码';
}
