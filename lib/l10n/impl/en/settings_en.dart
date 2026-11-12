import '../../keys/settings_keys.dart';

class SettingsEn implements SettingsLang {
  const SettingsEn();

  @override
  String get title => 'Settings';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutUsDescription =>
      '''<p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%'  style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">An open-source financial application developed using Flutter.</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>''';

  @override
  String get aboutPageDescription =>
      'This is an open-source project hosted on {github}, supporting Android, iOS, and Web platforms.\nYou can try the online version: {online}.\n\nIt is developed by jixiaoyong. The design is based on {picture} found on the internet.\n\nIf you have any questions, please contact me:';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get themeSystem => 'Follow system';

  @override
  String get translations => 'Translations';

  @override
  String get notifications => 'Notifications';

  @override
  String get generalInformation => 'General Information';

  @override
  String get localAddress => 'Local Address';

  @override
  String get notSet => 'Not set';

  @override
  String get person => 'Person';

  @override
  String get profile => 'Profile';

  @override
  String get readOnly => 'Read only';

  @override
  String get openNavigationMenu => 'Open navigation menu';

  @override
  String get viewReadOnlyProfile => 'View read-only profile';

  @override
  String get viewExistingWalletCards => 'View existing wallet cards';

  @override
  String get logout => 'Logout';

  @override
  String get logoutAndCleanData => 'Logout & Clean Data';

  @override
  String get sureToLogout => 'SureToLogout';

  @override
  String get cardManagement => 'Manage cards';
  @override
  String get cardManagementNotice =>
      'Manage cards in this app only, not your bank connections. Only the last four digits are shown; security codes are never displayed.';
  @override
  String get deleteCardQuestion => 'Delete card?';
  @override
  String get deleteCardNotice =>
      'This removes the card from this app only. Transaction history stays unchanged, and your bank account is not disconnected.';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get deleteFailed => 'Could not delete card. Try again.';
  @override
  String get notificationsDescription =>
      'Browse existing transactions by category and time. There is no separate notification service; categories use action labels, with unknown actions in Other.';
  @override
  String get undatedNotifications =>
      '{count} records have no parseable date (for example “Just now”) and are excluded from time filters.';
  @override
  String get transactionsLoadFailed =>
      'Unable to load transactions. Please try again later.';
  @override
  String get noTransactionNotifications =>
      'No transaction notifications for these filters';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';
  @override
  String get noCardsYetShort => 'No cards yet';
}
