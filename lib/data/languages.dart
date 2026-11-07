import '../core/localization/app_locale.dart';

/*
* @description: 全局强类型多语言门面，彻底杜绝手写双引号与拼写错误
*
* 任何业务使用直接通过 `Languages.key` 调用，
* 例如 `Languages.mon`, `Languages.login`, `Languages.passwordNotSame`。
* 享受 IDE 代码全量提示与编译期红线防错！
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class Languages {
  Languages._();

  // 基础导航与页面
  static String get home => AppLocale.translate("Home");
  static String get wallet => AppLocale.translate("Wallet");
  static String get search => AppLocale.translate("Search");
  static String get menu => AppLocale.translate("Menu");
  static String get history => AppLocale.translate("History");
  static String get person => AppLocale.translate("Person");
  static String get notifications => AppLocale.translate("Notifications");
  static String get settings => AppLocale.translate("Settings");
  static String get about => AppLocale.translate("About");

  // 星期
  static String get mon => AppLocale.translate("Mon");
  static String get tues => AppLocale.translate("Tues");
  static String get wed => AppLocale.translate("Wed");
  static String get thur => AppLocale.translate("Thur");
  static String get fri => AppLocale.translate("Fri");
  static String get satu => AppLocale.translate("Satu");
  static String get sun => AppLocale.translate("Sun");

  // 月份
  static String get january => AppLocale.translate("January");
  static String get february => AppLocale.translate("February");
  static String get march => AppLocale.translate("March");
  static String get april => AppLocale.translate("April");
  static String get may => AppLocale.translate("May");
  static String get june => AppLocale.translate("June");
  static String get july => AppLocale.translate("July");
  static String get august => AppLocale.translate("August");
  static String get september => AppLocale.translate("September");
  static String get october => AppLocale.translate("October");
  static String get november => AppLocale.translate("November");
  static String get december => AppLocale.translate("December");

  // 账户与认证
  static String get username => AppLocale.translate("Username");
  static String get password => AppLocale.translate("Password");
  static String get oldPassword => AppLocale.translate("Old Password");
  static String get newPassword => AppLocale.translate("New Password");
  static String get confirmPassword => AppLocale.translate("Confirm Password");
  static String get changePassword => AppLocale.translate("Change Password");
  static String get signIn => AppLocale.translate("Sign In");
  static String get signUp => AppLocale.translate("Sign Up");
  static String get login => AppLocale.translate("Login");
  static String get loginFailed => AppLocale.translate("Login Failed");
  static String get logout => AppLocale.translate("Logout");
  static String get logoutAndCleanData => AppLocale.translate("Logout & Clean Data");
  static String get cancel => AppLocale.translate("Cancel");
  static String get sureToLogout => AppLocale.translate("SureToLogout");
  static String get forgotPassword => AppLocale.translate("Forgot Password");
  static String get forgotPin => AppLocale.translate("Forgot PIN");
  static String get getStart => AppLocale.translate("Get Start");
  static String get setPasswordSucceed => AppLocale.translate("Set Password Succeed");
  static String get pleaseLoginWithNewPassword => AppLocale.translate("Please login with your new password.");
  static String get registerSucceed => AppLocale.translate("Register Succeed");
  static String get registerFailed => AppLocale.translate("Register Failed");
  static String get pleaseSignIn => AppLocale.translate("Please Sign In");
  static String get emailAddress => AppLocale.translate("Email Address");
  static String get verify => AppLocale.translate("verify");
  static String get submit => AppLocale.translate("Submit");

  // 表单校验提示
  static String get emailFormatNotCorrect => AppLocale.translate("the email format is not correct");
  static String get emailLengthMax => AppLocale.translate("the length of user email must be less than 30");
  static String get emailLengthMin => AppLocale.translate("the length of user email must be more than 5");
  static String get passwordNotSame => AppLocale.translate("the password is not same");
  static String get passwordLengthMax => AppLocale.translate("the length of user password must be less than 12");
  static String get passwordLengthMin => AppLocale.translate("the length of user password must be more than 6");
  static String get usernameLengthMax => AppLocale.translate("the length of username must be less than 10");
  static String get usernameLengthMin => AppLocale.translate("the length of username must be more than 3");
  static String get pleaseEnterVerifyCode => AppLocale.translate("Please enter the verify code we sent to your email:");

  // 钱包与卡片
  static String get availableBalance => AppLocale.translate("Available Balance");
  static String get totalSpending => AppLocale.translate("Total Spending");
  static String get send => AppLocale.translate("Send");
  static String get receive => AppLocale.translate("Receive");
  static String get cardCredit => AppLocale.translate("Card Credit");
  static String get addCard => AppLocale.translate("Add Card");
  static String get nameOnCard => AppLocale.translate("Name On Card");
  static String get cardNumber => AppLocale.translate("Card Number");
  static String get expireDate => AppLocale.translate("Expire Date");
  static String get pleaseTypeInYourName => AppLocale.translate("Please type in your name");
  static String get pleaseEnterBankCardNumber => AppLocale.translate("Please enter bank card number");
  static String get pleaseEnterExpirationDate => AppLocale.translate("Please enter an expiration date");

  // 业务与明细
  static String get translations => AppLocale.translate("Translations");
  static String get justNow => AppLocale.translate("Just now");
  static String get something => AppLocale.translate("Something");
  static String get category => AppLocale.translate("Category");
  static String get thisMonth => AppLocale.translate("this month");
  static String get thisWeek => AppLocale.translate("this week");
  static String get thisYear => AppLocale.translate("this year");
  static String get transfers => AppLocale.translate("Transfers");
  static String get recharge => AppLocale.translate("Recharge");
  static String get bill => AppLocale.translate("Bill");
  static String get others => AppLocale.translate("Others");

  // 其它
  static String get language => AppLocale.translate("Language");
  static String get fingerprintLogin => AppLocale.translate("Fingerprint Login");
  static String get loading => AppLocale.translate("Loading...");
  static String get profile => AppLocale.translate("Profile");
  static String get generalInformation => AppLocale.translate("General Information");
  static String get phoneNumber => AppLocale.translate("Phone Number");
  static String get localAddress => AppLocale.translate("Local Address");
  static String get aboutUsDescription => AppLocale.translate("AboutUsDescription");
  static String get explore => AppLocale.translate("Explore");
  static String get articles => AppLocale.translate("Articles");
  static String get hot => AppLocale.translate("Hot");
  static String get follow => AppLocale.translate("Follow");
  static String get stillWorkingOnIt => AppLocale.translate("still working on it");
  static String get somethingLikeAds => AppLocale.translate("something like ads");

  // 静态字典映射 (供 AppLocale.translate 查找)
  static Map<String, Map<String, String>> get keys => _keys;

  static final Map<String, Map<String, String>> _keys = {
    "en_US": {
      "MasterCard": "MasterCard",
      "Visa": "Visa",
      "Home": "Home",
      "Wallet": "Wallet",
      "Search": "Search",
      "Menu": "Menu",
      " Last Month": " Last Month",
      "History": "History",
      "Person": "Person",
      "Available Balance": "Available Balance",
      "Send": "Send",
      "Dashboard": "Dashboard",
      "Translations": "Translations",
      "Money Send": "Money Send",
      "Money Recharge": "Money Recharge",
      "Receive": "Receive",
      "Total": "Total",
      "Last Send": "Last Send",
      "Last Receive": "Last Receive",
      "Just now": "Just now",
      "Something": "Something",
      "Profile": "Profile",
      "Notifications": "Notifications",
      "Settings": "Settings",
      "About": "About us",
      "Total Spending": "Total Spending",
      "General Information": "General Information",
      "E-mail": "E-mail",
      "Phone Number": "Phone Number",
      "Local Address": "Local Address",
      "Card Credit": "Card Credit",
      "Add Card": "Add Card",
      "Language": "Language",
      "Change Password": "Change Password",
      "Fingerprint Login": "Fingerprint Login",
      "CNSS": "CNSS",
      "DXSS": "DXSS",
      "CID": "CID",
      "Mon": "Mon",
      "Tues": "Tues",
      "Wed": "Wed",
      "Thur": "Thur",
      "Fri": "Fri",
      "Satu": "Satu",
      "Sun": "Sun",
      "January": "January",
      "February": "February",
      "March": "March",
      "April": "April",
      "May": "May",
      "June": "June",
      "July": "July",
      "August": "August",
      "September": "September",
      "October": "October",
      "November": "November",
      "December": "December",
      "Category": "Category",
      "this month": "this month",
      "this week": "this week",
      "this year": "this year",
      "Transfers": "Transfers",
      "Recharge": "Recharge",
      "Bill": "Bill",
      "Others": "Others",
      "Login": "Login",
      "Don't Share Password": "Don't Share Password",
      "Use strong combinations of letters,numbers and special characters to make your password.":
          "Use strong combinations of letters,numbers and special characters to make your password.",
      "Forgot PIN": "Forgot PIN",
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.":
          "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.",
      "Manage Account": "Manage Account",
      "Bank account make more secure keeping transaction active and changing password regularly.":
          "Bank account make more secure keeping transaction active and changing password regularly.",
      "Sign In": "Sign In",
      "Sign Up": "Sign Up",
      "Forgot Password": "Forgot Password",
      "Enter your email address so we can send you a link to reset your password.":
          "Enter your email address so we can send you a link to reset your password.",
      "Username": "Username",
      "Password": "Password",
      "Login Failed": "Login Failed",
      "Loading...": "Loading...",
      "Logout": "Logout",
      "Old Password": "Old Password",
      "New Password": "New Password",
      "Confirm Password": "Confirm Password",
      "SureToLogout": "Are you sure you want to logout?\nThis will CLEAN ALL DATA",
      "Logout & Clean Data": "Logout & Clean Data",
      "Cancel": "Cancel",
      "Get Start": "Get Start",
      "Set Password Succeed": "Set Password Succeed",
      "Please login with your new password.": "Please login with your new password.",
      "Forget passwords?": "Forget passwords?",
      "Or Sign In With": "Or Sign In With",
      "I don't have an account": "I don't have an account",
      "Register Succeed": "Register Succeed",
      "Register Failed": "Register Failed",
      "Please Sign In": "Please Sign In",
      "Or Sign Up With": "Or Sign Up With",
      "I have already an account": "I have already an account",
      "Register": "Register",
      "Email Address": "Email Address",
      "Forget Password": "Forget Password",
      "Enter your email address to reset your password": "Enter your email address to reset your password",
      "verify": "verify",
      "Submit": "Submit",
      "the email format is not correct": "the email format is not correct",
      "the length of user email must be less than 30": "the length of user email must be less than 30",
      "the length of user email must be more than 5": "the length of user email must be more than 5",
      "the password is not same": "the password is not same",
      "the length of user password must be less than 12": "the length of user password must be less than 12",
      "the length of user password must be more than 6": "the length of user password must be more than 6",
      "the length of username must be less than 10": "the length of username must be less than 10",
      "the length of username must be more than 3": "the length of username must be more than 3",
      "Please enter the verify code we sent to your email:": "Please enter the verify code we sent to your email:",
      "Name On Card": "Name On Card",
      "Card Number": "Card Number",
      "Expire Date": "Expire Date",
      "Please type in your name": "Please type in your name",
      "Please enter bank card number": "Please enter bank card number",
      "Please enter an expiration date": "Please enter an expiration date",
      "AboutUsDescription":
          """<p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%' style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">an&nbsp;open-source&nbsp;Flutter&nbsp;financial&nbsp;application.</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>""",
      "Hot": "Hot",
      "Follow": "Follow",
      "Explore": "Explore",
      "Articles": "Articles",
      "still working on it": "still working on it",
      "something like ads": "something like ads>>>",
    },
    "zh_CN": {
      "MasterCard": "MasterCard卡",
      "Visa": "Visa卡",
      "Home": "首页",
      "Wallet": "钱包",
      "Search": "搜索",
      " Last Month": "上月",
      "History": "历史",
      "Person": "个人",
      "Available Balance": "可用余额",
      "Send": "发送",
      "Dashboard": "仪表盘",
      "Translations": "收支明细",
      "Money Send": "发送",
      "Money Recharge": "充值",
      "Receive": "接收",
      "Total": "总计",
      "Last Send": "上次发送",
      "Last Receive": "上次接收",
      "Just now": "刚刚",
      "Something": "某些",
      "Profile": "个人资料",
      "Notifications": "通知",
      "Settings": "设置",
      "About": "关于我们",
      "Total Spending": "总支出",
      "General Information": "一般信息",
      "E-mail": "电子邮件",
      "Phone Number": "电话号码",
      "Local Address": "本地地址",
      "Card Credit": "信用卡",
      "Add Card": "添加信用卡",
      "Language": "语言",
      "Change Password": "更改密码",
      "Fingerprint Login": "指纹登录",
      "CNSS": "招商银行",
      "DXSS": "中国银行",
      "CID": "农业银行",
      "Mon": "星期一",
      "Tues": "星期二",
      "Wed": "星期三",
      "Thur": "星期四",
      "Fri": "星期五",
      "Satu": "星期六",
      "Sun": "星期日",
      "January": "一月",
      "February": "二月",
      "March": "三月",
      "April": "四月",
      "May": "五月",
      "June": "六月",
      "July": "七月",
      "August": "八月",
      "September": "九月",
      "October": "十月",
      "November": "十一月",
      "December": "十二月",
      "Category": "类别",
      "this month": "本月",
      "this week": "本周",
      "this year": "本年",
      "Transfers": "转账",
      "Recharge": "充值",
      "Bill": "账单",
      "Others": "其他",
      "Don't Share Password": "不要分享密码",
      "Use strong combinations of letters,numbers and special characters to make your password.":
          "使用复杂的字母、数字和特殊字符组合来制作你的密码。",
      "Forgot PIN": "忘记密码",
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.":
          "不要太勉强自己，只需要电话联系银行，然后更改你的密码。",
      "Manage Account": "管理账户",
      "Bank account make more secure keeping transaction active and changing password regularly.":
          "想要银行账户更安全，请保持交易活动，并定期更改密码。",
      "Sign In": "登录",
      "Sign Up": "注册",
      "Forgot Password": "忘记密码",
      "Enter your email address so we can send you a link to reset your password.":
          "输入你的电子邮件地址，我们可以发送一个链接到重置密码。",
      "Username": "用户名",
      "Password": "密码",
      "Old Password": "旧密码",
      "New Password": "新密码",
      "Confirm Password": "确认密码",
      "Login Failed": "登录失败",
      "Loading...": "加载中...",
      "Logout": "退出登录",
      "Logout & Clean Data": "退出登录并清除数据",
      "Cancel": "取消",
      "SureToLogout": "您确定要退出吗？\n这将清除所有数据！",
      "Get Start": "开始",
      "Set Password Succeed": "设置密码成功",
      "Please login with your new password.": "请使用您的新密码登录。",
      "Forget passwords?": "忘记密码？",
      "Or Sign In With": "或通过下述方式登录",
      "I don't have an account": "我没有账户",
      "Login": "登录",
      "Register Succeed": "注册成功",
      "Register Failed": "注册失败",
      "Please Sign In": "请登录",
      "Or Sign Up With": "或通过下述方式注册",
      "I have already an account": "我已经有一个帐户",
      "Register": "注册",
      "Email Address": "电子邮件",
      "Forget Password": "忘记密码",
      "Enter your email address to reset your password": "输入您的电子邮件地址来重置您的密码",
      "verify": "获取验证码",
      "Submit": "提交",
      "the email format is not correct": "电子邮件格式不正确",
      "the length of user email must be less than 30": "用户电子邮件长度必须小于30",
      "the length of user email must be more than 5": "用户电子邮件长度必须大于5",
      "the password is not same": "密码不一样",
      "the length of user password must be less than 12": "用户密码长度必须小于12",
      "the length of user password must be more than 6": "用户密码长度必须大于6",
      "the length of username must be less than 10": "用户名长度必须小于10",
      "the length of username must be more than 3": "用户名长度必须大于3",
      "Please enter the verify code we sent to your email:": "请输入我们发送到您邮箱的验证码：",
      "Menu": "菜单",
      "Name On Card": "卡片上的名字",
      "Card Number": "卡号",
      "Expire Date": "到期日期",
      "Please type in your name": "请输入您的姓名",
      "Please enter bank card number": "请输入银行卡号",
      "Please enter an expiration date": "请输入有效期",
      "AboutUsDescription":
          """<p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%'  style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">一款使用Flutter开发的开源金融类应用。</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>""",
      "Follow": "关注",
      "Hot": "热门",
      "Explore": "探索",
      "Articles": "文章",
      "still working on it": "仍在努力开发中",
      "something like ads": "假装这里有广告>>>",
    }
  };
}
