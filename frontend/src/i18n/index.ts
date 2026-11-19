export type SupportedLang = 'zh' | 'en';

export interface I18nResources {
  // Common
  copied: string;
  copy: string;
  back: string;
  currencySymbol: string;

  // Master Nav
  heroEyebrow: string;
  heroTitle: string;
  heroDesc: string;
  telemetryCards: string;
  telemetryCurrencies: string;
  telemetryHotline: string;
  sectionServices: string;
  sectionServicesMeta: string;
  sectionGlance: string;
  sectionGlanceMeta: string;

  // Nav Items
  navEmergencyTitle: string;
  navEmergencyDesc: string;
  navEmergencyTag: string;
  navCurrencyTitle: string;
  navCurrencyDesc: string;
  navCurrencyTag: string;
  navPrivilegeTitle: string;
  navPrivilegeDesc: string;
  navPrivilegeTag: string;

  // Glance
  glanceCurrencySub: string;
  glanceEmergencyHead: string;
  glanceEmergencySub: string;

  // Emergency View
  emergencyCalloutTitle: string;
  emergencyCalloutDesc: string;
  emergencySectionCards: string;
  emergencySectionCardsMeta: string;
  emergencyHotlineTitle: string;
  emergencyHotlineSub: string;
  emergencySmsTitle: string;
  emergencySmsSub: string;
  emergencySmsCopyBtn: string;
  emergencySmsCopiedToast: string;
  emergencyPhoneCopiedToast: string;
  emergencySmsTemplate: (owner: string, card: string) => string;
  emergencyTipsTitle: string;
  emergencyTip1: string;
  emergencyTip2: string;

  // Currency View
  currencySectionLabel: string;
  currencySectionMeta: string;
  currencyCalculatorTitle: string;
  currencyCalculatorSub: string;
  currencyCalculatorBtn: string;
  currencyDccTitle: string;
  currencyDccDesc: string;
  currencyDccItem1: string;
  currencyDccItem2: string;
  currencyDccItem3: string;
  currencyCalcUnit: string;
  currencyCalcTitle: string;
  currencyPreset100: string;
  currencyPreset500: string;
  currencyPreset1000: string;
  currencyPreset2000: string;
  currencyDccLossText: (min: string, max: string) => string;

  // Privilege View
  privilegeCalloutTitle: string;
  privilegeCalloutDesc: string;
  privilegeSectionLabel: string;
  privilegeSectionMeta: string;
  privilegeCipTitle: string;
  privilegeCipDesc: string;
  privilegeCipCount: string;
  privilegeLoungeTitle: string;
  privilegeLoungeDesc: string;
  privilegeLoungeCount: string;
  privilegeReceiptBannerTitle: string;
  privilegeReceiptBannerSub: string;
  privilegeReceiptBannerBtn: string;

  // Receipt View
  receiptMerchant: string;
  receiptSubtitle: string;
  receiptStatus: string;
  receiptAuthCode: string;
  receiptCardTail: string;
  receiptType: string;
  receiptTerminal: string;
  receiptRefNo: string;
  receiptItemTitle: string;
  receiptItemDesc: string;
  receiptAmount: string;
  receiptTip: string;
  receiptTotal: string;
  receiptBarcodeSub: string;
  receiptNotice: string;
  receiptRefreshCodeBtn: string;
  receiptToastRefreshed: string;
}

const zh: I18nResources = {
  copied: '已复制',
  copy: '复制',
  back: '返回',
  currencySymbol: '¥',

  heroEyebrow: 'SIRC COMPANION · ',
  heroTitle: '随行中心',
  heroDesc: '断网飞行或境外弱网状态下，银行卡应急挂失、基准汇率折算与商旅凭证均支持本地零延迟查验。',
  telemetryCards: '受保护卡片',
  telemetryCurrencies: '基准币种',
  telemetryHotline: '全球紧急专线',
  sectionServices: '核心随行服务',
  sectionServicesMeta: '随行保险库',
  sectionGlance: '高频速览',
  sectionGlanceMeta: '点击进入',

  navEmergencyTitle: '紧急卡片与全球救援',
  navEmergencyDesc: '离线卡片凭据与 24 小时挂失专线',
  navEmergencyTag: '3 张卡',
  navCurrencyTitle: '汇率换算与境外用卡',
  navCurrencyDesc: '四大主流币种实时折算与 DCC 避坑',
  navCurrencyTag: '7.245',
  navPrivilegeTitle: '尊享权益与消费签单',
  navPrivilegeDesc: '全球机场 CIP 贵宾厅与交易凭单',
  navPrivilegeTag: 'CIP',

  glanceCurrencySub: '打开汇率与 DCC 换算',
  glanceEmergencyHead: '挂失直拨',
  glanceEmergencySub: '北辰信用社 · 尾号 0042',

  emergencyCalloutTitle: '紧急止付保护',
  emergencyCalloutDesc: '无网络或境外断网环境下，点击下方已加密缓存的银行卡即可直接拨打 24 小时挂失专线或复制应急报案短信。',
  emergencySectionCards: '已保护卡片',
  emergencySectionCardsMeta: '3 张卡 · 点击操作',
  emergencyHotlineTitle: '24 小时紧急止付专线',
  emergencyHotlineSub: '支持境外主叫与全球反欺诈人工接听',
  emergencySmsTitle: '弱网短信报案模版',
  emergencySmsSub: '信号微弱无法通话时，可一键复制并发送至发卡行应急短信中心。',
  emergencySmsCopyBtn: '复制应急报案短信',
  emergencySmsCopiedToast: '已复制应急报案短信模版',
  emergencyPhoneCopiedToast: '已复制挂失专线号码',
  emergencySmsTemplate: (owner, card) =>
    `【紧急挂失】本人 ${owner}，卡号 ${card}，遭遇紧急情况申请临时止付，请立即协助核实。`,
  emergencyTipsTitle: '境外用卡安全提示',
  emergencyTip1: '境外 POS 刷卡提示输入密码时，国际卡组织卡片通常仅需签名或 4 位 PIN，请勿重复尝试触发风控锁卡。',
  emergencyTip2: '结账时请确保卡片始终在视线范围内，谨防非法读卡器侧录磁条信息与背面安全码。',

  currencySectionLabel: '基准汇率',
  currencySectionMeta: '对人民币 · 点击换算',
  currencyCalculatorTitle: '离线汇率换算器',
  currencyCalculatorSub: '零网络依赖 · 毫秒级外币实时对账',
  currencyCalculatorBtn: '进入汇率换算器',
  currencyDccTitle: '境外刷卡 DCC 避坑指南 (Dynamic Currency Conversion)',
  currencyDccDesc: '在境外 POS 机刷卡时，收银员或 POS 机若提示选择结算币种：',
  currencyDccItem1: '务必坚决勾选 **当地法定货币**（例如美国选 USD，欧洲选 EUR，日本选 JPY）。',
  currencyDccItem2: '严禁勾选“人民币结算 (CNY)”！DCC 汇率通常暗含 3% – 5% 隐形手续费与极差汇率。',
  currencyDccItem3: '若小票已被打印成 CNY，有权当场要求收银员撤销（Void/Cancel）并以当地货币重刷。',
  currencyCalcUnit: '基准比价',
  currencyCalcTitle: '实时汇率折算',
  currencyPreset100: '100',
  currencyPreset500: '500',
  currencyPreset1000: '1,000',
  currencyPreset2000: '2,000',
  currencyDccLossText: (min, max) =>
    `若在刷卡机误选人民币计价，本笔消费预计多付 <strong class="tabular" style="color: var(--sirc-error);">¥${min} – ¥${max}</strong> 隐形汇差。结账时请明确告知收银员 <strong>Local Currency Only</strong>。`,

  privilegeCalloutTitle: '商旅尊享凭据',
  privilegeCalloutDesc: '断网或飞行模式下，向合作机场贵宾室或免税商户出示本卡片权益凭证即可核销。',
  privilegeSectionLabel: '已生效权益',
  privilegeSectionMeta: '2 项有效权益',
  privilegeCipTitle: '全球机场 CIP 快速安检通道',
  privilegeCipDesc: '北辰信用社 Visa Signature · 支持本地核销',
  privilegeCipCount: '余 4 次',
  privilegeLoungeTitle: '国际机场贵宾室 LoungeKey',
  privilegeLoungeDesc: '港湾社区银行卡片 · 出示条码入座',
  privilegeLoungeCount: '无限次',
  privilegeReceiptBannerTitle: '消费交易签单',
  privilegeReceiptBannerSub: '机上或无网场所生成标准对账凭单',
  privilegeReceiptBannerBtn: '生成交易凭证小票',

  receiptMerchant: 'SIRC COMPANION BOUTIQUE',
  receiptSubtitle: 'OFFLINE PURCHASE MEMO · 离线消费底单',
  receiptStatus: '交易状态 (STATUS)',
  receiptAuthCode: '离线授权码 (AUTH CODE)',
  receiptCardTail: '结算卡号 (PAY METHOD)',
  receiptType: '卡组织类型 (SCHEME)',
  receiptTerminal: '终端编号 (TERMINAL)',
  receiptRefNo: '凭证编号 (REF NO)',
  receiptItemTitle: '空中免税臻选礼遇 (Duty Free Selected)',
  receiptItemDesc: '数量: 1 · 离线固定额度预授权',
  receiptAmount: '小计 (SUBTOTAL)',
  receiptTip: '服务费与税费 (TAX/FEE 0%)',
  receiptTotal: '合计金额 (TOTAL AMOUNT)',
  receiptBarcodeSub: '扫码或由地勤录入收单流水号',
  receiptNotice: '注：本单为离线预授权凭证，将在恢复网络后同步至发卡行记账。',
  receiptRefreshCodeBtn: '重新生成凭单校验流水',
  receiptToastRefreshed: '已刷新签单编号',
};

const en: I18nResources = {
  copied: 'Copied',
  copy: 'Copy',
  back: 'Back',
  currencySymbol: '¥',

  heroEyebrow: 'SIRC COMPANION · ',
  heroTitle: 'Companion Hub',
  heroDesc: 'Emergency card lock, benchmark FX rates, and travel privileges verified locally with zero delay.',
  telemetryCards: 'Protected Cards',
  telemetryCurrencies: 'Base Currencies',
  telemetryHotline: 'Global Hotline',
  sectionServices: 'Core Companion Services',
  sectionServicesMeta: 'LOCAL VAULT',
  sectionGlance: 'Quick Glance',
  sectionGlanceMeta: 'TAP TO OPEN',

  navEmergencyTitle: 'Emergency Cards & Support',
  navEmergencyDesc: 'Card credentials & 24h emergency hotline',
  navEmergencyTag: '3 Cards',
  navCurrencyTitle: 'FX Rates & Card Tips',
  navCurrencyDesc: '4 major currencies & DCC warning guide',
  navCurrencyTag: '7.245',
  navPrivilegeTitle: 'Privileges & Offline Receipts',
  navPrivilegeDesc: 'Airport CIP lounges & verified vouchers',
  navPrivilegeTag: 'CIP',

  glanceCurrencySub: 'Open FX & DCC Converter',
  glanceEmergencyHead: 'Hotline Direct',
  glanceEmergencySub: 'North Star CU · Tail 0042',

  emergencyCalloutTitle: 'Emergency Lock Protection',
  emergencyCalloutDesc: 'When offline or roaming, tap any encrypted card below to call 24h hotline or copy report SMS template.',
  emergencySectionCards: 'Protected Cards',
  emergencySectionCardsMeta: '3 CARDS · TAP FOR ACTION',
  emergencyHotlineTitle: '24h Emergency Hotline',
  emergencyHotlineSub: 'Supports international calling & global fraud desk',
  emergencySmsTitle: 'Weak Network SMS Template',
  emergencySmsSub: 'When cell voice fails, copy and send directly to emergency SMS center.',
  emergencySmsCopyBtn: 'Copy Emergency SMS',
  emergencySmsCopiedToast: 'Emergency SMS copied to clipboard',
  emergencyPhoneCopiedToast: 'Hotline number copied',
  emergencySmsTemplate: (owner, card) =>
    `[Emergency Alert] I am ${owner}, card ${card}, requesting temporary emergency lock due to incident. Please verify immediately.`,
  emergencyTipsTitle: 'Overseas Card Safety Tips',
  emergencyTip1: 'When POS prompts for PIN, international cards usually require signature or 4-digit PIN. Avoid repeated attempts.',
  emergencyTip2: 'Keep card in sight at all times during checkout to prevent skimming of magnetic stripe or CVV.',

  currencySectionLabel: 'Benchmark FX Rates',
  currencySectionMeta: 'BASE CNY · TAP TO CONVERT',
  currencyCalculatorTitle: 'Offline FX Converter',
  currencyCalculatorSub: 'Zero network required · Real-time conversion',
  currencyCalculatorBtn: 'Open FX Converter',
  currencyDccTitle: 'DCC Avoidance Guide (Dynamic Currency Conversion)',
  currencyDccDesc: 'When checkout POS prompts to choose billing currency:',
  currencyDccItem1: 'Always choose **Local Currency** (e.g. USD in US, EUR in Europe, JPY in Japan).',
  currencyDccItem2: 'Never choose home currency (CNY)! DCC usually carries 3% – 5% hidden markup and unfavorable rates.',
  currencyDccItem3: 'If receipt shows CNY, you have the right to request Void/Cancel and charge in local currency.',
  currencyCalcUnit: 'Base Rate',
  currencyCalcTitle: 'FX Conversion',
  currencyPreset100: '100',
  currencyPreset500: '500',
  currencyPreset1000: '1,000',
  currencyPreset2000: '2,000',
  currencyDccLossText: (min, max) =>
    `If billed in CNY at POS, you may pay an extra <strong class="tabular" style="color: var(--sirc-error);">¥${min} – ¥${max}</strong> in hidden fees. Always tell cashier: <strong>Local Currency Only</strong>.`,

  privilegeCalloutTitle: 'Travel Privilege Voucher',
  privilegeCalloutDesc: 'In flight or offline mode, show this voucher to partner lounges or duty-free shops to redeem.',
  privilegeSectionLabel: 'Active Privileges',
  privilegeSectionMeta: '2 ACTIVE BENEFITS',
  privilegeCipTitle: 'Global Airport CIP Fast-Track',
  privilegeCipDesc: 'North Star CU Visa Signature · Offline Verification',
  privilegeCipCount: '4 left',
  privilegeLoungeTitle: 'LoungeKey Airport Lounges',
  privilegeLoungeDesc: 'Harbor Community Bank · Show barcode for entry',
  privilegeLoungeCount: 'Unlimited',
  privilegeReceiptBannerTitle: 'Transaction Receipt',
  privilegeReceiptBannerSub: 'Standard reconciliation voucher in flight or offline',
  privilegeReceiptBannerBtn: 'Generate Transaction Receipt',

  receiptMerchant: 'SIRC COMPANION BOUTIQUE',
  receiptSubtitle: 'OFFLINE PURCHASE MEMO',
  receiptStatus: 'STATUS',
  receiptAuthCode: 'AUTH CODE',
  receiptCardTail: 'PAY METHOD',
  receiptType: 'CARD SCHEME',
  receiptTerminal: 'TERMINAL',
  receiptRefNo: 'REF NO',
  receiptItemTitle: 'Duty Free In-Flight Collection',
  receiptItemDesc: 'Qty: 1 · Pre-Auth Voucher',
  receiptAmount: 'SUBTOTAL',
  receiptTip: 'TAX/FEE (0%)',
  receiptTotal: 'TOTAL AMOUNT',
  receiptBarcodeSub: 'Scan or manually enter by ground desk',
  receiptNotice: 'Notice: This offline pre-authorization will synchronize with issuer once online.',
  receiptRefreshCodeBtn: 'Regenerate Voucher Number',
  receiptToastRefreshed: 'Voucher ID refreshed',
};

class I18nManager {
  private currentLang: SupportedLang = 'zh';
  private listeners: Array<(lang: SupportedLang) => void> = [];

  constructor() {
    // 默认尝试读取 html lang 或系统语言
    if (typeof document !== 'undefined' && document.documentElement.lang) {
      this.currentLang = document.documentElement.lang.startsWith('en') ? 'en' : 'zh';
    }
  }

  public get lang(): SupportedLang {
    return this.currentLang;
  }

  public get t(): I18nResources {
    return this.currentLang === 'en' ? en : zh;
  }

  public setLang(lang: SupportedLang | string): boolean {
    const target: SupportedLang = lang.toLowerCase().startsWith('en') ? 'en' : 'zh';
    if (this.currentLang === target) return false;
    this.currentLang = target;
    if (typeof document !== 'undefined') {
      document.documentElement.lang = target;
    }
    this.listeners.forEach((fn) => fn(target));
    return true;
  }

  public onLangChange(listener: (lang: SupportedLang) => void) {
    this.listeners.push(listener);
  }
}

export const i18n = new I18nManager();
