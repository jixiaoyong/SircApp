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
  String get hostedOnGithub => 'This is an open-source project hosted on ';

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
  String get logout => 'Logout';

  @override
  String get logoutAndCleanData => 'Logout & Clean Data';

  @override
  String get sureToLogout => 'SureToLogout';
}
