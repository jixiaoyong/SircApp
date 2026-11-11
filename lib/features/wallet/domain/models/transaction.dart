/// 交易流水领域实体模型 (Transaction)
class Transaction {
  Transaction({
    this.userIcon,
    this.moneyActionName,
    this.moneyAmount,
    this.time,
  });

  Transaction.fromJson(dynamic json) {
    userIcon = json['userIcon'];
    moneyActionName = json['moneyActionName'];
    moneyAmount = (json['moneyAmount'] as num?)?.toDouble();
    time = json['time'];
  }

  String? userIcon;
  String? moneyActionName;
  double? moneyAmount;
  String? time;

  Transaction copyWith({
    String? userIcon,
    String? moneyActionName,
    double? moneyAmount,
    String? time,
  }) => Transaction(
    userIcon: userIcon ?? this.userIcon,
    moneyActionName: moneyActionName ?? this.moneyActionName,
    moneyAmount: moneyAmount ?? this.moneyAmount,
    time: time ?? this.time,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userIcon'] = userIcon;
    map['moneyActionName'] = moneyActionName;
    map['moneyAmount'] = moneyAmount;
    map['time'] = time;
    return map;
  }
}
