import '../../keys/wallet_keys.dart';

class WalletZh implements WalletLang {
  const WalletZh();

  @override
  String get title => '钱包';

  @override
  String get wallet => '钱包';

  @override
  String get availableBalance => '可用余额';

  @override
  String get totalSpending => '总支出';

  @override
  String get lastMonth => '上月';

  @override
  String get thisMonth => '本月';

  @override
  String get thisWeek => '本周';

  @override
  String get thisYear => '本年';

  @override
  String get lastSend => '最近转出';

  @override
  String get lastReceive => '最近转入';

  @override
  String get total => '总计';

  @override
  String get addCard => '添加卡片';

  @override
  String get cardNumber => '卡号';

  @override
  String get nameOnCard => '卡片上的名字';

  @override
  String get expireDate => '到期日期';

  @override
  String get cvv => 'CVV';

  @override
  String get cardCredit => '卡片';

  @override
  String get pleaseEnterBankCardNumber => '请输入银行卡号';

  @override
  String get pleaseEnterExpirationDate => '请输入有效期';

  @override
  String get pleaseTypeInYourName => '请输入您的姓名';

  @override
  String get masterCard => '万事达卡';

  @override
  String get visa => '维萨卡';

  @override
  String get cnss => 'CNSS';

  @override
  String get dxss => 'DXSS';

  @override
  String get cid => 'CID';

  @override
  String get transfers => '转账';

  @override
  String get bill => '账单';

  @override
  String get recharge => '充值';

  @override
  String get moneyRecharge => '话费充值';

  @override
  String get moneySend => '转账';

  @override
  String get send => '发送';

  @override
  String get receive => '接收';

  @override
  String get history => '历史';

  @override
  String get details => '明细';

  @override
  String get transactionDetails => '交易详情';
  @override
  String get transactionUnavailable => '暂无交易详情';
  @override
  String get transactionType => '交易类型';
  @override
  String get amount => '金额';
  @override
  String get time => '时间';
  @override
  String get editCard => '编辑卡片';
  @override
  String get cardNotFound => '卡片不存在';
  @override
  String get cardLoading => '正在加载卡片…';
  @override
  String get saveCard => '保存';
  @override
  String get cardSaved => '卡片已保存';

  @override
  String get noTransactions => '暂无交易记录';

  @override
  String get outgoing => '转出';

  @override
  String get incoming => '转入';

  @override
  String cardCount(int count) => '共 $count 张卡片';
}
