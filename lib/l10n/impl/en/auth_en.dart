import '../../keys/auth_keys.dart';

class AuthEn implements AuthLang {
  const AuthEn();

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get registerSucceed => 'Register Succeed';

  @override
  String get registerFailed => 'Register Failed';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get addNewPassword => 'Add New Password';

  @override
  String get setPasswordSucceed => 'Set Password Succeed';

  @override
  String get pleaseLoginWithNewPassword =>
      'Please login with your new password.';

  @override
  String get oldPasswordIncorrect =>
      'Original password incorrect or update failed';

  @override
  String get passwordInconsistent =>
      'The passwords entered twice do not match';

  @override
  String get passwordNotSame => 'the password is not same';

  @override
  String get passwordMinLengthPrompt =>
      'Password length must not be less than 6 digits';

  @override
  String get passwordLengthMin =>
      'the length of user password must be more than 6';

  @override
  String get passwordLengthMax =>
      'the length of user password must be less than 12';

  @override
  String get usernameLengthMin =>
      'the length of username must be more than 3';

  @override
  String get usernameLengthMax =>
      'the length of username must be less than 10';

  @override
  String get email => 'E-mail';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailFormatNotCorrect => 'the email format is not correct';

  @override
  String get emailLengthMin => 'the length of user email must be more than 5';

  @override
  String get emailLengthMax =>
      'the length of user email must be less than 30';

  @override
  String get enterEmailToResetPassword =>
      'Enter your email address to reset your password';

  @override
  String get forgetPassword => 'Forget Password';

  @override
  String get forgetPasswords => 'Forget passwords?';

  @override
  String get forgotPin => 'Forgot PIN';

  @override
  String get forgotPinDetail =>
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.";

  @override
  String get dontSharePassword => "Don't Share Password";

  @override
  String get dontSharePasswordDetail =>
      "Use strong combinations of letters,numbers and special characters to make your password.";

  @override
  String get manageAccount => 'Manage Account';

  @override
  String get manageAccountDetail =>
      "Bank account make more secure keeping transaction active and changing password regularly.";

  @override
  String get orSignInWith => 'Or Sign In With';

  @override
  String get orSignUpWith => 'Or Sign Up With';

  @override
  String get haveAccount => 'I have already an account';

  @override
  String get dontHaveAccount => "I don't have an account";

  @override
  String get pleaseSignIn => 'Please Sign In';

  @override
  String get pleaseEnterVerifyCode =>
      'Please enter the verify code we sent to your email:';

  @override
  String get verify => 'verify';

  @override
  String get pleaseInputCurrentPassword =>
      'Please enter your current password first';

  @override
  String get pleaseInputNewPassword => 'Please enter a new password';

  @override
  String get pleaseInputConfirmPassword =>
      'Please enter the confirmation new password';

  @override
  String get fingerprintLogin => 'Fingerprint Login';

  @override
  String get phoneNumber => 'Phone Number';
}

