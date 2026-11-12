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
  String get cardCredit => 'Cards';

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
  String get transactionDetails => 'Transaction details';
  @override
  String get transactionUnavailable => 'Transaction details unavailable';
  @override
  String get transactionType => 'Transaction type';
  @override
  String get amount => 'Amount';
  @override
  String get time => 'Time';
  @override
  String get editCard => 'Edit card';
  @override
  String get cardNotFound => 'Card not found';
  @override
  String get cardLoading => 'Loading card…';
  @override
  String get saveCard => 'Save';
  @override
  String get cardSaved => 'Card saved';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get outgoing => 'Money Out';

  @override
  String get incoming => 'Money In';

  @override
  String get manageCards => 'Manage';
  @override
  String get transactions => 'Transactions';
  @override
  String get incomeExpenseStats => 'Income and spending';
  @override
  String get historyTotalAmount => 'Total transaction amount';
  @override
  String get amountAbsoluteSummary => 'Sum of absolute transaction amounts';
  @override
  String get recordsGroupedByWeekday => 'Selected records · grouped by weekday';
  @override
  String get filterByDate => 'Filter by date';
  @override
  String get transactionsLabel => 'transactions';
  @override
  String get searchTransactions => 'Search transactions';
  @override
  String get searchIncomeExpense => 'Search income or spending';
  @override
  String get previousCard => 'Previous card';
  @override
  String get nextCard => 'Next card';
  @override
  String get noCardsYet => 'No cards yet. Choose Add card to get started.';
  @override
  String get noMatchingTransactions => 'No transactions match these filters';
  @override
  String get noChartRecords => 'No records to summarize in the selected range';
  @override
  String get thisWeekSpending => 'This week · spending';
  @override
  String get thisWeekIncome => 'This week · income';
  @override
  String get thisWeekTotalVolume => 'This week · total volume';
  @override
  String get thisWeekdayLabel => 'MTWTFSS';
  @override
  String get undatedRecordsTooltip =>
      'Grouped using device date {date}; supports Today, Yesterday and ISO dates.';
  @override
  String get undatedRecordsExcluded => '{count} undated records excluded';

  @override
  String cardCount(int count) =>
      count == 1 ? '1 card in total' : '$count cards in total';
}
