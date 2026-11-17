import '../../keys/home_keys.dart';

class HomeZh implements HomeLang {
  const HomeZh();

  @override
  String get payloadTitle => '网页模块';
  @override
  String get payloadLoading => '正在加载本地模块…';
  @override
  String get payloadError => '本地模块加载失败。';
  @override
  String get payloadRetry => '重试';
  @override
  String get payloadBuiltIn => '仅使用内置资源 · 尚未配置更新地址';
  @override
  String get payloadOnline => '已配置更新服务';
  @override
  String get payloadWebUnsupported =>
      '离线资源包仅适用于原生应用，请在 Android 或 iOS 上打开 SircApp。';
  @override
  String get payloadPlatformUnsupported =>
      '当前平台暂无受支持的 WebView，请使用 Android 或 iOS。';
  @override
  String get payloadRestore => '恢复内置版本';
  @override
  String get payloadBack => '返回模块上一页';
  @override
  String get payloadHeading => 'Sirc 随行';
  @override
  String get payloadDescription => '本地随行模块已就绪，无网络时也可查看。';
  @override
  String get payloadVersion => '资源版本';
  @override
  String get payloadUpdating => '正在检查或下载更新…';
  @override
  String get payloadUpdateFailed => '更新暂不可用，仍可使用本地资源。';
  @override
  String get payloadUpdated => '资源已是最新版本';
  @override
  String get payloadUpdateAvailable => '新版本已就绪，切换将刷新模块。';
  @override
  String get payloadActivateUpdate => '切换并刷新';

  @override
  String get title => '首页';

  @override
  String get home => '首页';

  @override
  String get dashboard => '控制面板';

  @override
  String get follow => '关注';

  @override
  String get hot => '热门';

  @override
  String get explore => '探索';

  @override
  String get articles => '文章';

  @override
  String get getStart => '开始';

  @override
  String get somethingLikeAds => '假装这里有广告>>>';

  @override
  String get stillWorkingOnIt => '仍在努力开发中';

  @override
  String get justNow => '刚刚';

  @override
  String get noCardsInWallet => '暂无卡片，请前往钱包添加';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get transactionSummary => '交易摘要';

  @override
  String get localExamples => '本地示例';

  @override
  String get articleNotFound => '未找到文章';

  @override
  String get articleDisclaimer => '本地静态示例 · 未连接文章服务 · 非投资建议';

  @override
  String get transactionActivity => '交易活动';

  @override
  String get chartWeek => '本周';
  @override
  String get chartMonth => '本月';
  @override
  String get chartVolume => '每日交易总额';
  @override
  String get chartVolumeHint => '收入与支出绝对值之和，非余额或净额';
  @override
  String get chartEmpty => '本周期暂无交易';
  @override
  String get chartZero => '每日交易总额均为零';
  @override
  String get chartFuture => '尚未到该日期';
  @override
  String get chartUndated => '日期不明确的记录未计入';

  @override
  String get bonds => '债券';
  @override
  String get billing => '账单';
  @override
  String get cash => '现金';
  @override
  String get moneyBag => '钱袋';
  @override
  String get bouncedCheck => '退票';
  @override
  String get tax => '税务';
  @override
  String get purchaseOrder => '采购订单';
  @override
  String get paymentHistory => '付款记录';
  @override
  String get cardInUse => '用卡';
  @override
  String get cardSecurity => '卡片安全';
  @override
  String get bankCardFrontSide => '卡片正面';
  @override
  String get bankCardMissing => '卡片遗失';
  @override
  String get creditControl => '信用管理';
  @override
  String get commodity => '商品';

  @override
  String get mon => '周一';

  @override
  String get tues => '周二';

  @override
  String get wed => '周三';

  @override
  String get thur => '周四';

  @override
  String get fri => '周五';

  @override
  String get satu => '周六';

  @override
  String get sun => '周日';

  @override
  String get january => '一月';

  @override
  String get february => '二月';

  @override
  String get march => '三月';

  @override
  String get april => '四月';

  @override
  String get may => '五月';

  @override
  String get june => '六月';

  @override
  String get july => '七月';

  @override
  String get august => '八月';

  @override
  String get september => '九月';

  @override
  String get october => '十月';

  @override
  String get november => '十一月';

  @override
  String get december => '十二月';
}
