import '../../keys/wallet_keys.dart';

class WalletEn implements WalletLang {
  const WalletEn();

  @override
  String get title => 'Wallet';

  @override
  String get wallet => 'Wallet';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get lastMonth => ' Last Month';

  @override
  String get thisMonth => 'this month';

  @override
  String get thisWeek => 'this week';

  @override
  String get thisYear => 'this year';

  @override
  String get lastSend => 'Last Send';

  @override
  String get lastReceive => 'Last Receive';

  @override
  String get total => 'Total';

  @override
  String get addCard => 'Add Card';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get nameOnCard => 'Name On Card';

  @override
  String get expireDate => 'Expire Date';

  @override
  String get cvv => 'CVV';

  @override
  String get cardCredit => 'Card Credit';

  @override
  String get pleaseEnterBankCardNumber => 'Please enter bank card number';

  @override
  String get pleaseEnterExpirationDate => 'Please enter an expiration date';

  @override
  String get pleaseTypeInYourName => 'Please type in your name';

  @override
  String get masterCard => 'MasterCard';

  @override
  String get visa => 'Visa';

  @override
  String get cnss => 'CNSS';

  @override
  String get dxss => 'DXSS';

  @override
  String get cid => 'CID';

  @override
  String get transfers => 'Transfers';

  @override
  String get bill => 'Bill';

  @override
  String get recharge => 'Recharge';

  @override
  String get moneyRecharge => 'Money Recharge';

  @override
  String get moneySend => 'Money Send';

  @override
  String get send => 'Send';

  @override
  String get receive => 'Receive';

  @override
  String get history => 'History';

  @override
  String get details => 'Details';

  @override
  String cardCount(int count) => count == 1 ? '1 card in total' : '$count cards in total';
}
