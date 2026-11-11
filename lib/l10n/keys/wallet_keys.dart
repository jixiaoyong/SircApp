/// 钱包、银行卡、交易流水及财务词条契约
abstract class WalletLang {
  String get title;
  String get wallet;
  String get availableBalance;
  String get totalSpending;
  String get lastMonth;
  String get thisMonth;
  String get thisWeek;
  String get thisYear;
  String get lastSend;
  String get lastReceive;
  String get total;
  String get addCard;
  String get cardNumber;
  String get nameOnCard;
  String get expireDate;
  String get cvv;
  String get cardCredit;
  String get pleaseEnterBankCardNumber;
  String get pleaseEnterExpirationDate;
  String get pleaseTypeInYourName;
  String get masterCard;
  String get visa;
  String get cnss;
  String get dxss;
  String get cid;
  String get transfers;
  String get bill;
  String get recharge;
  String get moneyRecharge;
  String get moneySend;
  String get send;
  String get receive;
  String get history;
  String get details;
  String get noTransactions;
  String get outgoing;
  String get incoming;

  /// 单复数支持示例：银行卡数量统计
  String cardCount(int count);
}
