import '../../keys/settings_keys.dart';

class SettingsZh implements SettingsLang {
  const SettingsZh();

  @override
  String get title => '设置';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get aboutUsDescription =>
      '''<p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='30%'  style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">一款使用Flutter开发的开源金融类应用。</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>''';

  @override
  String get hostedOnGithub => '这是一个开源项目，托管于 ';

  @override
  String get language => '语言';

  @override
  String get translations => '翻译';

  @override
  String get notifications => '通知';

  @override
  String get generalInformation => '通用信息';

  @override
  String get localAddress => '本地地址';

  @override
  String get notSet => '未设置';

  @override
  String get person => '个人';

  @override
  String get profile => '个人资料';

  @override
  String get logout => '退出登录';

  @override
  String get logoutAndCleanData => '退出登录并清除数据';

  @override
  String get sureToLogout => '您确定要退出吗？\n这将清除所有数据！';
}
