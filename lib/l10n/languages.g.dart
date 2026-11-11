// GENERATED CODE - DO NOT MODIFY BY HAND
// 该文件由脚本自动维护。如需新增或修改多语言词条：
// 1. 在 `lib/l10n/keys/` 中声明对应模块属性
// 2. 在 `lib/l10n/impl/zh/` 和 `lib/l10n/impl/en/` 中实现中英文翻译
// 3. 执行更新命令：
//    - 手动单次生成：`dart run tool/build_lang.dart`
//    - 后台监听实时生成：`dart run tool/build_lang.dart --watch`

import '../core/localization/app_locale.dart';

/*
* @description: 全局强类型分层多语言门面
*
* 1. 支持业务分层命名空间调用：
*    例如 Languages.auth.oldPasswordIncorrect、Languages.wallet.availableBalance
* 2. 完整保留扁平别名调用（平滑兼容历史代码）：
*    例如 Languages.oldPasswordIncorrect、Languages.cancel
* 3. 具备双语悬浮预览注释，敲代码时鼠标移至属性即可查看中英真实文案！
*
* 自动生成命令：
* - 手动执行：dart run tool/build_lang.dart
* - 实时监听：dart run tool/build_lang.dart --watch
*/
class Languages {
  Languages._();

  // ==========================================
  // 一、 业务分层命名空间（Layered Namespaces）
  // ==========================================

  /// 认证、账号、密码及表单校验词条命名空间
  static AuthLang get auth => AppLocale.current.auth;

  /// 钱包、银行卡、交易流水及财务词条命名空间
  static WalletLang get wallet => AppLocale.current.wallet;

  /// 首页、看板、月份、星期及快捷分类词条命名空间
  static HomeLang get home => AppLocale.current.home;

  /// 设置、关于、个人资料、通知及退出登录词条命名空间
  static SettingsLang get settings => AppLocale.current.settings;

  /// 通用公共词条（按钮、状态、缺省页等）命名空间
  static CommonLang get common => AppLocale.current.common;

  // ==========================================
  // 二、 扁平兼容层（带双语悬浮预览注释）
  // ==========================================

  // --- Auth 模块 ---
  ///- [zh_CN] 登录
  ///- [en_US] Sign In
  static String get signIn => auth.signIn;

  ///- [zh_CN] 注册
  ///- [en_US] Sign Up
  static String get signUp => auth.signUp;

  ///- [zh_CN] 登录
  ///- [en_US] Login
  static String get login => auth.login;

  ///- [zh_CN] 注册
  ///- [en_US] Register
  static String get register => auth.register;

  ///- [zh_CN] 登录失败
  ///- [en_US] Login Failed
  static String get loginFailed => auth.loginFailed;

  ///- [zh_CN] 注册成功
  ///- [en_US] Register Succeed
  static String get registerSucceed => auth.registerSucceed;

  ///- [zh_CN] 注册失败
  ///- [en_US] Register Failed
  static String get registerFailed => auth.registerFailed;

  ///- [zh_CN] 用户名
  ///- [en_US] Username
  static String get username => auth.username;

  ///- [zh_CN] 密码
  ///- [en_US] Password
  static String get password => auth.password;

  ///- [zh_CN] 旧密码
  ///- [en_US] Old Password
  static String get oldPassword => auth.oldPassword;

  ///- [zh_CN] 新密码
  ///- [en_US] New Password
  static String get newPassword => auth.newPassword;

  ///- [zh_CN] 确认密码
  ///- [en_US] Confirm Password
  static String get confirmPassword => auth.confirmPassword;

  ///- [zh_CN] 修改密码
  ///- [en_US] Change Password
  static String get changePassword => auth.changePassword;

  ///- [zh_CN] 设置新密码
  ///- [en_US] Add New Password
  static String get addNewPassword => auth.addNewPassword;

  ///- [zh_CN] 设置密码成功
  ///- [en_US] Set Password Succeed
  static String get setPasswordSucceed => auth.setPasswordSucceed;

  ///- [zh_CN] 请使用您的新密码登录。
  ///- [en_US] Please login with your new password.
  static String get pleaseLoginWithNewPassword =>
      auth.pleaseLoginWithNewPassword;

  ///- [zh_CN] 原密码不正确或修改失败
  ///- [en_US] Original password incorrect or update failed
  static String get oldPasswordIncorrect => auth.oldPasswordIncorrect;

  ///- [zh_CN] 两次输入的密码不一致
  ///- [en_US] The passwords entered twice do not match
  static String get passwordInconsistent => auth.passwordInconsistent;

  ///- [zh_CN] 密码不一样
  ///- [en_US] the password is not same
  static String get passwordNotSame => auth.passwordNotSame;

  ///- [zh_CN] 密码长度不能小于6位
  ///- [en_US] Password length must not be less than 6 digits
  static String get passwordMinLengthPrompt => auth.passwordMinLengthPrompt;

  ///- [zh_CN] 用户密码长度必须大于6
  ///- [en_US] the length of user password must be more than 6
  static String get passwordLengthMin => auth.passwordLengthMin;

  ///- [zh_CN] 用户密码长度必须小于12
  ///- [en_US] the length of user password must be less than 12
  static String get passwordLengthMax => auth.passwordLengthMax;

  ///- [zh_CN] 用户名长度必须大于3
  ///- [en_US] the length of username must be more than 3
  static String get usernameLengthMin => auth.usernameLengthMin;

  ///- [zh_CN] 用户名长度必须小于10
  ///- [en_US] the length of username must be less than 10
  static String get usernameLengthMax => auth.usernameLengthMax;

  ///- [zh_CN] 电子邮件
  ///- [en_US] E-mail
  static String get email => auth.email;

  ///- [zh_CN] 电子邮件
  ///- [en_US] Email Address
  static String get emailAddress => auth.emailAddress;

  ///- [zh_CN] 电子邮件格式不正确
  ///- [en_US] the email format is not correct
  static String get emailFormatNotCorrect => auth.emailFormatNotCorrect;

  ///- [zh_CN] 用户电子邮件长度必须大于5
  ///- [en_US] the length of user email must be more than 5
  static String get emailLengthMin => auth.emailLengthMin;

  ///- [zh_CN] 用户电子邮件长度必须小于30
  ///- [en_US] the length of user email must be less than 30
  static String get emailLengthMax => auth.emailLengthMax;

  ///- [zh_CN] 输入您的电子邮件地址来重置您的密码
  ///- [en_US] Enter your email address to reset your password
  static String get enterEmailToResetPassword => auth.enterEmailToResetPassword;

  ///- [zh_CN] 忘记密码
  ///- [en_US] Forget Password
  static String get forgetPassword => auth.forgetPassword;

  ///- [zh_CN] 忘记密码？
  ///- [en_US] Forget passwords?
  static String get forgetPasswords => auth.forgetPasswords;

  ///- [zh_CN] 忘记密码
  ///- [en_US] Forgot PIN
  static String get forgotPin => auth.forgotPin;

  ///- [zh_CN] 不用担心PIN码\n只需致电银行即可更改PIN码。
  ///- [en_US] Don't take too much tension about PiN\nJust make ono call to bank and change your pin.
  static String get forgotPinDetail => auth.forgotPinDetail;

  ///- [zh_CN] 不要分享密码
  ///- [en_US] Don't Share Password
  static String get dontSharePassword => auth.dontSharePassword;

  ///- [zh_CN] 使用字母、数字和特殊字符的强组合来设置密码。
  ///- [en_US] Use strong combinations of letters,numbers and special characters to make your password.
  static String get dontSharePasswordDetail => auth.dontSharePasswordDetail;

  ///- [zh_CN] 管理账户
  ///- [en_US] Manage Account
  static String get manageAccount => auth.manageAccount;

  ///- [zh_CN] 银行账户保持交易活跃并定期更改密码更安全。
  ///- [en_US] Bank account make more secure keeping transaction active and changing password regularly.
  static String get manageAccountDetail => auth.manageAccountDetail;

  ///- [zh_CN] 或通过下述方式登录
  ///- [en_US] Or Sign In With
  static String get orSignInWith => auth.orSignInWith;

  ///- [zh_CN] 或通过下述方式注册
  ///- [en_US] Or Sign Up With
  static String get orSignUpWith => auth.orSignUpWith;

  ///- [zh_CN] 我已经有一个帐户
  ///- [en_US] I have already an account
  static String get haveAccount => auth.haveAccount;

  ///- [zh_CN] 我没有账户
  ///- [en_US] I don't have an account
  static String get dontHaveAccount => auth.dontHaveAccount;

  ///- [zh_CN] 请登录
  ///- [en_US] Please Sign In
  static String get pleaseSignIn => auth.pleaseSignIn;

  ///- [zh_CN] 请输入我们发送到您邮箱的验证码：
  ///- [en_US] Please enter the verify code we sent to your email:
  static String get pleaseEnterVerifyCode => auth.pleaseEnterVerifyCode;

  ///- [zh_CN] 获取验证码
  ///- [en_US] verify
  static String get verify => auth.verify;

  ///- [zh_CN] 请先输入现有密码
  ///- [en_US] Please enter your current password first
  static String get pleaseInputCurrentPassword =>
      auth.pleaseInputCurrentPassword;

  ///- [zh_CN] 请输入新密码
  ///- [en_US] Please enter a new password
  static String get pleaseInputNewPassword => auth.pleaseInputNewPassword;

  ///- [zh_CN] 请输入确认新密码
  ///- [en_US] Please enter the confirmation new password
  static String get pleaseInputConfirmPassword =>
      auth.pleaseInputConfirmPassword;

  ///- [zh_CN] 指纹登录
  ///- [en_US] Fingerprint Login
  static String get fingerprintLogin => auth.fingerprintLogin;

  ///- [zh_CN] 电话号码
  ///- [en_US] Phone Number
  static String get phoneNumber => auth.phoneNumber;

  // --- Wallet 模块 ---
  ///- [zh_CN] 钱包
  ///- [en_US] Wallet
  static String get walletTitle => wallet.title;

  ///- [zh_CN] 可用余额
  ///- [en_US] Available Balance
  static String get availableBalance => wallet.availableBalance;

  ///- [zh_CN] 总支出
  ///- [en_US] Total Spending
  static String get totalSpending => wallet.totalSpending;

  ///- [zh_CN] 上月
  ///- [en_US]  Last Month
  static String get lastMonth => wallet.lastMonth;

  ///- [zh_CN] 本月
  ///- [en_US] this month
  static String get thisMonth => wallet.thisMonth;

  ///- [zh_CN] 本周
  ///- [en_US] this week
  static String get thisWeek => wallet.thisWeek;

  ///- [zh_CN] 本年
  ///- [en_US] this year
  static String get thisYear => wallet.thisYear;

  ///- [zh_CN] 最近转出
  ///- [en_US] Last Send
  static String get lastSend => wallet.lastSend;

  ///- [zh_CN] 最近转入
  ///- [en_US] Last Receive
  static String get lastReceive => wallet.lastReceive;

  ///- [zh_CN] 总计
  ///- [en_US] Total
  static String get total => wallet.total;

  ///- [zh_CN] 添加卡片
  ///- [en_US] Add Card
  static String get addCard => wallet.addCard;

  ///- [zh_CN] 卡号
  ///- [en_US] Card Number
  static String get cardNumber => wallet.cardNumber;

  ///- [zh_CN] 卡片上的名字
  ///- [en_US] Name On Card
  static String get nameOnCard => wallet.nameOnCard;

  ///- [zh_CN] 到期日期
  ///- [en_US] Expire Date
  static String get expireDate => wallet.expireDate;

  ///- [zh_CN] CVV
  ///- [en_US] CVV
  static String get cvv => wallet.cvv;

  ///- [zh_CN] 卡片
  ///- [en_US] Cards
  static String get cardCredit => wallet.cardCredit;

  ///- [zh_CN] 请输入银行卡号
  ///- [en_US] Please enter bank card number
  static String get pleaseEnterBankCardNumber =>
      wallet.pleaseEnterBankCardNumber;

  ///- [zh_CN] 请输入有效期
  ///- [en_US] Please enter an expiration date
  static String get pleaseEnterExpirationDate =>
      wallet.pleaseEnterExpirationDate;

  ///- [zh_CN] 请输入您的姓名
  ///- [en_US] Please type in your name
  static String get pleaseTypeInYourName => wallet.pleaseTypeInYourName;

  ///- [zh_CN] 万事达卡
  ///- [en_US] MasterCard
  static String get masterCard => wallet.masterCard;

  ///- [zh_CN] 维萨卡
  ///- [en_US] Visa
  static String get visa => wallet.visa;

  ///- [zh_CN] CNSS
  ///- [en_US] CNSS
  static String get cnss => wallet.cnss;

  ///- [zh_CN] DXSS
  ///- [en_US] DXSS
  static String get dxss => wallet.dxss;

  ///- [zh_CN] CID
  ///- [en_US] CID
  static String get cid => wallet.cid;

  ///- [zh_CN] 转账
  ///- [en_US] Transfers
  static String get transfers => wallet.transfers;

  ///- [zh_CN] 账单
  ///- [en_US] Bill
  static String get bill => wallet.bill;

  ///- [zh_CN] 充值
  ///- [en_US] Recharge
  static String get recharge => wallet.recharge;

  ///- [zh_CN] 话费充值
  ///- [en_US] Money Recharge
  static String get moneyRecharge => wallet.moneyRecharge;

  ///- [zh_CN] 转账
  ///- [en_US] Money Send
  static String get moneySend => wallet.moneySend;

  ///- [zh_CN] 发送
  ///- [en_US] Send
  static String get send => wallet.send;

  ///- [zh_CN] 接收
  ///- [en_US] Receive
  static String get receive => wallet.receive;

  ///- [zh_CN] 历史
  ///- [en_US] History
  static String get history => wallet.history;

  ///- [zh_CN] 明细
  ///- [en_US] Details
  static String get details => wallet.details;

  ///- [zh_CN] 暂无交易记录
  ///- [en_US] No transactions yet
  static String get noTransactions => wallet.noTransactions;

  ///- [zh_CN] 转出
  ///- [en_US] Money Out
  static String get outgoing => wallet.outgoing;

  ///- [zh_CN] 转入
  ///- [en_US] Money In
  static String get incoming => wallet.incoming;

  // --- Home 模块 ---
  ///- [zh_CN] 首页
  ///- [en_US] Home
  static String get homeTitle => home.title;

  ///- [zh_CN] 控制面板
  ///- [en_US] Dashboard
  static String get dashboard => home.dashboard;

  ///- [zh_CN] 关注
  ///- [en_US] Follow
  static String get follow => home.follow;

  ///- [zh_CN] 热门
  ///- [en_US] Hot
  static String get hot => home.hot;

  ///- [zh_CN] 探索
  ///- [en_US] Explore
  static String get explore => home.explore;

  ///- [zh_CN] 文章
  ///- [en_US] Articles
  static String get articles => home.articles;

  ///- [zh_CN] 开始
  ///- [en_US] Get Start
  static String get getStart => home.getStart;

  ///- [zh_CN] 假装这里有广告>>>
  ///- [en_US] something like ads
  static String get somethingLikeAds => home.somethingLikeAds;

  ///- [zh_CN] 仍在努力开发中
  ///- [en_US] still working on it
  static String get stillWorkingOnIt => home.stillWorkingOnIt;

  ///- [zh_CN] 刚刚
  ///- [en_US] Just now
  static String get justNow => home.justNow;

  ///- [zh_CN] 暂无卡片，请前往钱包添加
  ///- [en_US] No cards yet. Add a card in Wallet.
  static String get noCardsInWallet => home.noCardsInWallet;

  ///- [zh_CN] 最近交易
  ///- [en_US] Transactions
  static String get recentTransactions => home.recentTransactions;

  ///- [zh_CN] 交易摘要
  ///- [en_US] Transaction summary
  static String get transactionSummary => home.transactionSummary;

  ///- [zh_CN] 本地示例
  ///- [en_US] Local examples
  static String get localExamples => home.localExamples;

  ///- [zh_CN] 本周
  ///- [en_US] This week
  static String get chartWeek => home.chartWeek;

  ///- [zh_CN] 本月
  ///- [en_US] This month
  static String get chartMonth => home.chartMonth;

  ///- [zh_CN] 每日交易总额
  ///- [en_US] Daily transaction volume
  static String get chartVolume => home.chartVolume;

  ///- [zh_CN] 收入与支出绝对值之和，非余额或净额
  ///- [en_US] Absolute income + expense, not balance or net amount
  static String get chartVolumeHint => home.chartVolumeHint;

  ///- [zh_CN] 本周期暂无交易
  ///- [en_US] No transactions in this period
  static String get chartEmpty => home.chartEmpty;

  ///- [zh_CN] 每日交易总额均为零
  ///- [en_US] All daily transaction amounts are zero
  static String get chartZero => home.chartZero;

  ///- [zh_CN] 尚未到该日期
  ///- [en_US] Future date
  static String get chartFuture => home.chartFuture;

  ///- [zh_CN] 日期不明确的记录未计入
  ///- [en_US] Records with unknown dates excluded
  static String get chartUndated => home.chartUndated;

  ///- [zh_CN] 债券
  ///- [en_US] Bonds
  static String get bonds => home.bonds;

  ///- [zh_CN] 账单
  ///- [en_US] Billing
  static String get billing => home.billing;

  ///- [zh_CN] 现金
  ///- [en_US] Cash
  static String get cash => home.cash;

  ///- [zh_CN] 钱袋
  ///- [en_US] Money Bag
  static String get moneyBag => home.moneyBag;

  ///- [zh_CN] 退票
  ///- [en_US] Bounced Check
  static String get bouncedCheck => home.bouncedCheck;

  ///- [zh_CN] 税务
  ///- [en_US] Tax
  static String get tax => home.tax;

  ///- [zh_CN] 采购订单
  ///- [en_US] Purchase Order
  static String get purchaseOrder => home.purchaseOrder;

  ///- [zh_CN] 付款记录
  ///- [en_US] Payment History
  static String get paymentHistory => home.paymentHistory;

  ///- [zh_CN] 用卡
  ///- [en_US] Card In Use
  static String get cardInUse => home.cardInUse;

  ///- [zh_CN] 卡片安全
  ///- [en_US] Card Security
  static String get cardSecurity => home.cardSecurity;

  ///- [zh_CN] 卡片正面
  ///- [en_US] Card Front Side
  static String get bankCardFrontSide => home.bankCardFrontSide;

  ///- [zh_CN] 卡片遗失
  ///- [en_US] Card Missing
  static String get bankCardMissing => home.bankCardMissing;

  ///- [zh_CN] 信用管理
  ///- [en_US] Credit Control
  static String get creditControl => home.creditControl;

  ///- [zh_CN] 商品
  ///- [en_US] Commodity
  static String get commodity => home.commodity;

  ///- [zh_CN] 周一
  ///- [en_US] Mon
  static String get mon => home.mon;

  ///- [zh_CN] 周二
  ///- [en_US] Tues
  static String get tues => home.tues;

  ///- [zh_CN] 周三
  ///- [en_US] Wed
  static String get wed => home.wed;

  ///- [zh_CN] 周四
  ///- [en_US] Thur
  static String get thur => home.thur;

  ///- [zh_CN] 周五
  ///- [en_US] Fri
  static String get fri => home.fri;

  ///- [zh_CN] 周六
  ///- [en_US] Satu
  static String get satu => home.satu;

  ///- [zh_CN] 周日
  ///- [en_US] Sun
  static String get sun => home.sun;

  ///- [zh_CN] 一月
  ///- [en_US] January
  static String get january => home.january;

  ///- [zh_CN] 二月
  ///- [en_US] February
  static String get february => home.february;

  ///- [zh_CN] 三月
  ///- [en_US] March
  static String get march => home.march;

  ///- [zh_CN] 四月
  ///- [en_US] April
  static String get april => home.april;

  ///- [zh_CN] 五月
  ///- [en_US] May
  static String get may => home.may;

  ///- [zh_CN] 六月
  ///- [en_US] June
  static String get june => home.june;

  ///- [zh_CN] 七月
  ///- [en_US] July
  static String get july => home.july;

  ///- [zh_CN] 八月
  ///- [en_US] August
  static String get august => home.august;

  ///- [zh_CN] 九月
  ///- [en_US] September
  static String get september => home.september;

  ///- [zh_CN] 十月
  ///- [en_US] October
  static String get october => home.october;

  ///- [zh_CN] 十一月
  ///- [en_US] November
  static String get november => home.november;

  ///- [zh_CN] 十二月
  ///- [en_US] December
  static String get december => home.december;

  // --- Settings 模块 ---
  ///- [zh_CN] <p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%'  style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">一款使用Flutter开发的开源金融类应用。</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>
  ///- [en_US] <p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%'  style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">An open-source financial application developed using Flutter.</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>
  static String get aboutUsDescription => settings.aboutUsDescription;

  ///- [zh_CN] 设置
  ///- [en_US] Settings
  static String get settingsTitle => settings.title;

  ///- [zh_CN] 关于
  ///- [en_US] About
  static String get about => settings.about;

  ///- [zh_CN] 这是一个开源项目，托管于
  ///- [en_US] This is an open-source project hosted on
  static String get hostedOnGithub => settings.hostedOnGithub;

  ///- [zh_CN] 语言
  ///- [en_US] Language
  static String get language => settings.language;

  ///- [zh_CN] 外观主题
  ///- [en_US] Appearance
  static String get appearance => settings.appearance;

  ///- [zh_CN] 亮色
  ///- [en_US] Light
  static String get themeLight => settings.themeLight;

  ///- [zh_CN] 暗色
  ///- [en_US] Dark
  static String get themeDark => settings.themeDark;

  ///- [zh_CN] 跟随系统
  ///- [en_US] Follow system
  static String get themeSystem => settings.themeSystem;

  ///- [zh_CN] 翻译
  ///- [en_US] Translations
  static String get translations => settings.translations;

  ///- [zh_CN] 通知
  ///- [en_US] Notifications
  static String get notifications => settings.notifications;

  ///- [zh_CN] 通用信息
  ///- [en_US] General Information
  static String get generalInformation => settings.generalInformation;

  ///- [zh_CN] 本地地址
  ///- [en_US] Local Address
  static String get localAddress => settings.localAddress;

  ///- [zh_CN] 未设置
  ///- [en_US] Not set
  static String get notSet => settings.notSet;

  ///- [zh_CN] 个人
  ///- [en_US] Person
  static String get person => settings.person;

  ///- [zh_CN] 个人资料
  ///- [en_US] Profile
  static String get profile => settings.profile;

  ///- [zh_CN] 退出登录
  ///- [en_US] Logout
  static String get logout => settings.logout;

  ///- [zh_CN] 退出登录并清除数据
  ///- [en_US] Logout & Clean Data
  static String get logoutAndCleanData => settings.logoutAndCleanData;

  ///- [zh_CN] 您确定要退出吗？\n这将清除所有数据！
  ///- [en_US] SureToLogout
  static String get sureToLogout => settings.sureToLogout;

  // --- Common 模块 ---
  ///- [zh_CN] 取消
  ///- [en_US] Cancel
  static String get cancel => common.cancel;

  ///- [zh_CN] 提交
  ///- [en_US] Submit
  static String get submit => common.submit;

  ///- [zh_CN] 加载中...
  ///- [en_US] Loading...
  static String get loading => common.loading;

  ///- [zh_CN] 搜索
  ///- [en_US] Search
  static String get search => common.search;

  ///- [zh_CN] 菜单
  ///- [en_US] Menu
  static String get menu => common.menu;

  ///- [zh_CN] 类别
  ///- [en_US] Category
  static String get category => common.category;

  ///- [zh_CN] 其他
  ///- [en_US] Others
  static String get others => common.others;

  ///- [zh_CN] 某件事
  ///- [en_US] Something
  static String get something => common.something;

  ///- [zh_CN] 页面未找到
  ///- [en_US] Not Found
  static String get notFound => common.notFound;

  ///- [zh_CN] 返回首页
  ///- [en_US] Go to Home
  static String get goToHome => common.goToHome;

  // ==========================================
  // 三、 兼容字典映射 (供 AppLocale.translate 兜底查找)
  // ==========================================
  static Map<String, Map<String, String>> get keys => _keys;

  static final Map<String, Map<String, String>> _keys = {
    "en_US": {
      "Sign In": "Sign In",
      "Sign Up": "Sign Up",
      "Login": "Login",
      "Register": "Register",
      "Login Failed": "Login Failed",
      "Register Succeed": "Register Succeed",
      "Register Failed": "Register Failed",
      "Username": "Username",
      "Password": "Password",
      "Old Password": "Old Password",
      "New Password": "New Password",
      "Confirm Password": "Confirm Password",
      "Change Password": "Change Password",
      "Add New Password": "Add New Password",
      "Set Password Succeed": "Set Password Succeed",
      "Please login with your new password.":
          "Please login with your new password.",
      "Original password incorrect or update failed":
          "Original password incorrect or update failed",
      "The passwords entered twice do not match":
          "The passwords entered twice do not match",
      "the password is not same": "the password is not same",
      "Password length must not be less than 6 digits":
          "Password length must not be less than 6 digits",
      "the length of user password must be more than 6":
          "the length of user password must be more than 6",
      "the length of user password must be less than 12":
          "the length of user password must be less than 12",
      "the length of username must be more than 3":
          "the length of username must be more than 3",
      "the length of username must be less than 10":
          "the length of username must be less than 10",
      "E-mail": "E-mail",
      "Email Address": "Email Address",
      "the email format is not correct": "the email format is not correct",
      "the length of user email must be more than 5":
          "the length of user email must be more than 5",
      "the length of user email must be less than 30":
          "the length of user email must be less than 30",
      "Enter your email address to reset your password":
          "Enter your email address to reset your password",
      "Forget Password": "Forget Password",
      "Forget passwords?": "Forget passwords?",
      "Forgot PIN": "Forgot PIN",
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.": "Don't take too much tension about PiN\\nJust make ono call to bank and change your pin.",
      "Don't Share Password": "Don't Share Password",
      "Use strong combinations of letters,numbers and special characters to make your password.": "Use strong combinations of letters,numbers and special characters to make your password.",
      "Manage Account": "Manage Account",
      "Bank account make more secure keeping transaction active and changing password regularly.": "Bank account make more secure keeping transaction active and changing password regularly.",
      "Or Sign In With": "Or Sign In With",
      "Or Sign Up With": "Or Sign Up With",
      "I have already an account": "I have already an account",
      "I don't have an account": "I don't have an account",
      "Please Sign In": "Please Sign In",
      "Please enter the verify code we sent to your email:":
          "Please enter the verify code we sent to your email:",
      "verify": "verify",
      "Please enter your current password first":
          "Please enter your current password first",
      "Please enter a new password": "Please enter a new password",
      "Please enter the confirmation new password":
          "Please enter the confirmation new password",
      "Fingerprint Login": "Fingerprint Login",
      "Phone Number": "Phone Number",
      "Wallet": "Wallet",
      "Wallet": "Wallet",
      "Available Balance": "Available Balance",
      "Total Spending": "Total Spending",
      " Last Month": " Last Month",
      "this month": "this month",
      "this week": "this week",
      "this year": "this year",
      "Last Send": "Last Send",
      "Last Receive": "Last Receive",
      "Total": "Total",
      "Add Card": "Add Card",
      "Card Number": "Card Number",
      "Name On Card": "Name On Card",
      "Expire Date": "Expire Date",
      "CVV": "CVV",
      "Cards": "Cards",
      "Please enter bank card number": "Please enter bank card number",
      "Please enter an expiration date": "Please enter an expiration date",
      "Please type in your name": "Please type in your name",
      "MasterCard": "MasterCard",
      "Visa": "Visa",
      "CNSS": "CNSS",
      "DXSS": "DXSS",
      "CID": "CID",
      "Transfers": "Transfers",
      "Bill": "Bill",
      "Recharge": "Recharge",
      "Money Recharge": "Money Recharge",
      "Money Send": "Money Send",
      "Send": "Send",
      "Receive": "Receive",
      "History": "History",
      "Details": "Details",
      "No transactions yet": "No transactions yet",
      "Money Out": "Money Out",
      "Money In": "Money In",
      "Home": "Home",
      "Home": "Home",
      "Dashboard": "Dashboard",
      "Follow": "Follow",
      "Hot": "Hot",
      "Explore": "Explore",
      "Articles": "Articles",
      "Get Start": "Get Start",
      "something like ads": "something like ads",
      "still working on it": "still working on it",
      "Just now": "Just now",
      "No cards yet. Add a card in Wallet.":
          "No cards yet. Add a card in Wallet.",
      "Transactions": "Transactions",
      "Transaction summary": "Transaction summary",
      "Local examples": "Local examples",
      "This week": "This week",
      "This month": "This month",
      "Daily transaction volume": "Daily transaction volume",
      "Absolute income + expense, not balance or net amount":
          "Absolute income + expense, not balance or net amount",
      "No transactions in this period": "No transactions in this period",
      "All daily transaction amounts are zero":
          "All daily transaction amounts are zero",
      "Future date": "Future date",
      "Records with unknown dates excluded":
          "Records with unknown dates excluded",
      "Bonds": "Bonds",
      "Billing": "Billing",
      "Cash": "Cash",
      "Money Bag": "Money Bag",
      "Bounced Check": "Bounced Check",
      "Tax": "Tax",
      "Purchase Order": "Purchase Order",
      "Payment History": "Payment History",
      "Card In Use": "Card In Use",
      "Card Security": "Card Security",
      "Card Front Side": "Card Front Side",
      "Card Missing": "Card Missing",
      "Credit Control": "Credit Control",
      "Commodity": "Commodity",
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
      "Settings": "Settings",
      "Settings": "Settings",
      "About": "About",
      "This is an open-source project hosted on ":
          "This is an open-source project hosted on ",
      "Language": "Language",
      "Appearance": "Appearance",
      "Light": "Light",
      "Dark": "Dark",
      "Follow system": "Follow system",
      "Translations": "Translations",
      "Notifications": "Notifications",
      "General Information": "General Information",
      "Local Address": "Local Address",
      "Not set": "Not set",
      "Person": "Person",
      "Profile": "Profile",
      "Logout": "Logout",
      "Logout & Clean Data": "Logout & Clean Data",
      "SureToLogout": "SureToLogout",
      "Cancel": "Cancel",
      "Submit": "Submit",
      "Loading...": "Loading...",
      "Search": "Search",
      "Menu": "Menu",
      "Category": "Category",
      "Others": "Others",
      "Something": "Something",
      "Not Found": "Not Found",
      "Go to Home": "Go to Home",
    },
    "zh_CN": {
      "Sign In": "登录",
      "Sign Up": "注册",
      "Login": "登录",
      "Register": "注册",
      "Login Failed": "登录失败",
      "Register Succeed": "注册成功",
      "Register Failed": "注册失败",
      "Username": "用户名",
      "Password": "密码",
      "Old Password": "旧密码",
      "New Password": "新密码",
      "Confirm Password": "确认密码",
      "Change Password": "修改密码",
      "Add New Password": "设置新密码",
      "Set Password Succeed": "设置密码成功",
      "Please login with your new password.": "请使用您的新密码登录。",
      "Original password incorrect or update failed": "原密码不正确或修改失败",
      "The passwords entered twice do not match": "两次输入的密码不一致",
      "the password is not same": "密码不一样",
      "Password length must not be less than 6 digits": "密码长度不能小于6位",
      "the length of user password must be more than 6": "用户密码长度必须大于6",
      "the length of user password must be less than 12": "用户密码长度必须小于12",
      "the length of username must be more than 3": "用户名长度必须大于3",
      "the length of username must be less than 10": "用户名长度必须小于10",
      "E-mail": "电子邮件",
      "Email Address": "电子邮件",
      "the email format is not correct": "电子邮件格式不正确",
      "the length of user email must be more than 5": "用户电子邮件长度必须大于5",
      "the length of user email must be less than 30": "用户电子邮件长度必须小于30",
      "Enter your email address to reset your password": "输入您的电子邮件地址来重置您的密码",
      "Forget Password": "忘记密码",
      "Forget passwords?": "忘记密码？",
      "Forgot PIN": "忘记密码",
      "Don't take too much tension about PiN\nJust make ono call to bank and change your pin.":
          "不用担心PIN码\\n只需致电银行即可更改PIN码。",
      "Don't Share Password": "不要分享密码",
      "Use strong combinations of letters,numbers and special characters to make your password.":
          "使用字母、数字和特殊字符的强组合来设置密码。",
      "Manage Account": "管理账户",
      "Bank account make more secure keeping transaction active and changing password regularly.":
          "银行账户保持交易活跃并定期更改密码更安全。",
      "Or Sign In With": "或通过下述方式登录",
      "Or Sign Up With": "或通过下述方式注册",
      "I have already an account": "我已经有一个帐户",
      "I don't have an account": "我没有账户",
      "Please Sign In": "请登录",
      "Please enter the verify code we sent to your email:": "请输入我们发送到您邮箱的验证码：",
      "verify": "获取验证码",
      "Please enter your current password first": "请先输入现有密码",
      "Please enter a new password": "请输入新密码",
      "Please enter the confirmation new password": "请输入确认新密码",
      "Fingerprint Login": "指纹登录",
      "Phone Number": "电话号码",
      "Wallet": "钱包",
      "Wallet": "钱包",
      "Available Balance": "可用余额",
      "Total Spending": "总支出",
      " Last Month": "上月",
      "this month": "本月",
      "this week": "本周",
      "this year": "本年",
      "Last Send": "最近转出",
      "Last Receive": "最近转入",
      "Total": "总计",
      "Add Card": "添加卡片",
      "Card Number": "卡号",
      "Name On Card": "卡片上的名字",
      "Expire Date": "到期日期",
      "CVV": "CVV",
      "Cards": "卡片",
      "Please enter bank card number": "请输入银行卡号",
      "Please enter an expiration date": "请输入有效期",
      "Please type in your name": "请输入您的姓名",
      "MasterCard": "万事达卡",
      "Visa": "维萨卡",
      "CNSS": "CNSS",
      "DXSS": "DXSS",
      "CID": "CID",
      "Transfers": "转账",
      "Bill": "账单",
      "Recharge": "充值",
      "Money Recharge": "话费充值",
      "Money Send": "转账",
      "Send": "发送",
      "Receive": "接收",
      "History": "历史",
      "Details": "明细",
      "No transactions yet": "暂无交易记录",
      "Money Out": "转出",
      "Money In": "转入",
      "Home": "首页",
      "Home": "首页",
      "Dashboard": "控制面板",
      "Follow": "关注",
      "Hot": "热门",
      "Explore": "探索",
      "Articles": "文章",
      "Get Start": "开始",
      "something like ads": "假装这里有广告>>>",
      "still working on it": "仍在努力开发中",
      "Just now": "刚刚",
      "No cards yet. Add a card in Wallet.": "暂无卡片，请前往钱包添加",
      "Transactions": "最近交易",
      "Transaction summary": "交易摘要",
      "Local examples": "本地示例",
      "This week": "本周",
      "This month": "本月",
      "Daily transaction volume": "每日交易总额",
      "Absolute income + expense, not balance or net amount":
          "收入与支出绝对值之和，非余额或净额",
      "No transactions in this period": "本周期暂无交易",
      "All daily transaction amounts are zero": "每日交易总额均为零",
      "Future date": "尚未到该日期",
      "Records with unknown dates excluded": "日期不明确的记录未计入",
      "Bonds": "债券",
      "Billing": "账单",
      "Cash": "现金",
      "Money Bag": "钱袋",
      "Bounced Check": "退票",
      "Tax": "税务",
      "Purchase Order": "采购订单",
      "Payment History": "付款记录",
      "Card In Use": "用卡",
      "Card Security": "卡片安全",
      "Card Front Side": "卡片正面",
      "Card Missing": "卡片遗失",
      "Credit Control": "信用管理",
      "Commodity": "商品",
      "Mon": "周一",
      "Tues": "周二",
      "Wed": "周三",
      "Thur": "周四",
      "Fri": "周五",
      "Satu": "周六",
      "Sun": "周日",
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
      "Settings": "设置",
      "Settings": "设置",
      "About": "关于",
      "This is an open-source project hosted on ": "这是一个开源项目，托管于 ",
      "Language": "语言",
      "Appearance": "外观主题",
      "Light": "亮色",
      "Dark": "暗色",
      "Follow system": "跟随系统",
      "Translations": "翻译",
      "Notifications": "通知",
      "General Information": "通用信息",
      "Local Address": "本地地址",
      "Not set": "未设置",
      "Person": "个人",
      "Profile": "个人资料",
      "Logout": "退出登录",
      "Logout & Clean Data": "退出登录并清除数据",
      "SureToLogout": "您确定要退出吗？\\n这将清除所有数据！",
      "Cancel": "取消",
      "Submit": "提交",
      "Loading...": "加载中...",
      "Search": "搜索",
      "Menu": "菜单",
      "Category": "类别",
      "Others": "其他",
      "Something": "某件事",
      "Not Found": "页面未找到",
      "Go to Home": "返回首页",
    },
  };
}
