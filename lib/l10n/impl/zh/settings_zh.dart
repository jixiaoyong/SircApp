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
  String get aboutPageDescription =>
      '这是一个开源项目，托管于 {github}，支持 Android、iOS 和 Web 平台。\n你可以体验在线版本：{online}。\n\n由 jixiaoyong 开发，设计灵感来自 {picture}。\n\n如有任何问题，欢迎联系我：';

  @override
  String get language => '语言';

  @override
  String get appearance => '外观主题';
  @override
  String get themeLight => '亮色';
  @override
  String get themeDark => '暗色';
  @override
  String get themeSystem => '跟随系统';

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
  String get readOnly => '只读';

  @override
  String get openNavigationMenu => '打开导航菜单';

  @override
  String get viewReadOnlyProfile => '查看只读个人资料';

  @override
  String get viewExistingWalletCards => '查看钱包中的现有银行卡';

  @override
  String get logout => '退出登录';

  @override
  String get logoutAndCleanData => '退出登录并清除数据';

  @override
  String get sureToLogout => '您确定要退出吗？\n这将清除所有数据！';

  @override
  String get cardManagement => '卡片管理';
  @override
  String get cardManagementNotice => '仅管理本应用中的卡片，不会解绑真实银行账户。列表仅显示卡号尾号，不显示安全码。';
  @override
  String get deleteCardQuestion => '删除卡片？';
  @override
  String get deleteCardNotice => '仅从本应用移除此卡片，不会删除交易历史，也不会解绑真实银行账户。';
  @override
  String get delete => '删除';
  @override
  String get edit => '编辑';
  @override
  String get deleteFailed => '删除失败，请重试';
  @override
  String get notificationsDescription =>
      '按类别和时间查阅已有交易。当前无独立通知服务；类别由交易名称识别，未识别的归入其他。';
  @override
  String get notificationTitle => '交易通知';
  @override
  String get notificationEmptyState => '当前筛选下暂无交易通知';
  @override
  String get undatedNotifications => '{count} 条记录缺少可解析日期（如“刚刚”），未纳入时间筛选。';
  @override
  String get transactionsLoadFailed => '交易加载失败，请稍后重试。';
  @override
  String get noTransactionNotifications => '当前筛选下暂无交易通知';
  @override
  String get showPassword => '显示密码';
  @override
  String get hidePassword => '隐藏密码';
  @override
  String get noCardsYetShort => '暂无卡片';
  @override
  String get developerConsole => '开发者日志与诊断控制台';
  @override
  String get copyLogs => '复制日志';
  @override
  String get logsCopied => '日志已复制到剪贴板';
  @override
  String get clearLogs => '清空日志';
  @override
  String get logLevelAll => '全部';
  @override
  String get logLevelInfo => '信息';
  @override
  String get logLevelWarn => '警告';
  @override
  String get logLevelError => '错误';
  @override
  String get securityCredential => '安全认证凭据';
  @override
  String get credentialVerified => '已完成实名与安全验证';
  @override
  String get securityProtection => '此凭据用于双重验证、交易风控通知及重要密码找回。受端到端加密保护。';
  @override
  String get rebind => '申请换绑';
  @override
  String get copiedToClipboard => '已复制到剪贴板';
  @override
  String get userProfileTitle => '个人资料与账户安全';
  @override
  String get accountSecurity => '账户安全等级：极佳';
  @override
  String get devModeActivated => '已激活开发者调试控制台';
  @override
  String get imageCacheMemory => '内存缓存 (L1)';
  @override
  String get imageCacheDisk => '磁盘持久化 (L2)';
  @override
  String get clearMemoryCache => '清内存';
  @override
  String get clearDiskCache => '清磁盘';
  @override
  String get clearAllCache => '清理全部图片缓存';
  @override
  String get cacheClearedToast => '图片缓存已成功清理';
  @override
  String get diskCacheWebNotice => 'Web 端由浏览器 HTTP 强缓存接管';
}
