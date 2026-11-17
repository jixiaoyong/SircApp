import '../../keys/home_keys.dart';

class HomeEn implements HomeLang {
  const HomeEn();

  @override
  String get payloadTitle => 'Web module';
  @override
  String get payloadLoading => 'Loading local module…';
  @override
  String get payloadError => 'Unable to load the local module.';
  @override
  String get payloadRetry => 'Retry';
  @override
  String get payloadBuiltIn =>
      'Built-in resources only · no update URL configured';
  @override
  String get payloadOnline => 'Update service configured';
  @override
  String get payloadWebUnsupported =>
      'Offline packages require the native app. Please open SircApp on Android or iOS.';
  @override
  String get payloadPlatformUnsupported =>
      'This platform has no supported WebView. Please use Android or iOS.';
  @override
  String get payloadRestore => 'Restore built-in version';
  @override
  String get payloadBack => 'Back within module';
  @override
  String get payloadHeading => 'Sirc companion';
  @override
  String get payloadDescription =>
      'Your local companion is ready, even without a network connection.';
  @override
  String get payloadVersion => 'Resource version';
  @override
  String get payloadUpdating => 'Checking or downloading updates…';
  @override
  String get payloadUpdateFailed =>
      'Update unavailable; local resources remain available.';
  @override
  String get payloadUpdated => 'Resources up to date';
  @override
  String get payloadUpdateAvailable =>
      'New version ready; switching reloads the module.';
  @override
  String get payloadActivateUpdate => 'Switch and refresh';

  @override
  String get title => 'Home';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get follow => 'Follow';

  @override
  String get hot => 'Hot';

  @override
  String get explore => 'Explore';

  @override
  String get articles => 'Articles';

  @override
  String get getStart => 'Get Start';

  @override
  String get somethingLikeAds => 'something like ads';

  @override
  String get stillWorkingOnIt => 'still working on it';

  @override
  String get justNow => 'Just now';

  @override
  String get noCardsInWallet => 'No cards yet. Add a card in Wallet.';

  @override
  String get recentTransactions => 'Transactions';

  @override
  String get transactionSummary => 'Transaction summary';

  @override
  String get localExamples => 'Local examples';

  @override
  String get articleNotFound => 'Article not found';

  @override
  String get articleDisclaimer =>
      'Static example · Local content · No article service connected · Not investment advice';

  @override
  String get transactionActivity => 'Transaction activity';

  @override
  String get chartWeek => 'This week';
  @override
  String get chartMonth => 'This month';
  @override
  String get chartVolume => 'Daily transaction volume';
  @override
  String get chartVolumeHint =>
      'Absolute income + expense, not balance or net amount';
  @override
  String get chartEmpty => 'No transactions in this period';
  @override
  String get chartZero => 'All daily transaction amounts are zero';
  @override
  String get chartFuture => 'Future date';
  @override
  String get chartUndated => 'Records with unknown dates excluded';

  @override
  String get bonds => 'Bonds';
  @override
  String get billing => 'Billing';
  @override
  String get cash => 'Cash';
  @override
  String get moneyBag => 'Money Bag';
  @override
  String get bouncedCheck => 'Bounced Check';
  @override
  String get tax => 'Tax';
  @override
  String get purchaseOrder => 'Purchase Order';
  @override
  String get paymentHistory => 'Payment History';
  @override
  String get cardInUse => 'Card In Use';
  @override
  String get cardSecurity => 'Card Security';
  @override
  String get bankCardFrontSide => 'Card Front Side';
  @override
  String get bankCardMissing => 'Card Missing';
  @override
  String get creditControl => 'Credit Control';
  @override
  String get commodity => 'Commodity';

  @override
  String get mon => 'Mon';

  @override
  String get tues => 'Tues';

  @override
  String get wed => 'Wed';

  @override
  String get thur => 'Thur';

  @override
  String get fri => 'Fri';

  @override
  String get satu => 'Satu';

  @override
  String get sun => 'Sun';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';
}
