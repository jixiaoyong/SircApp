/// 交易流水领域实体模型 (Transaction)
class Transaction {
  Transaction({
    this.userIcon,
    this.moneyActionName,
    this.moneyAmount,
    this.time,
    this.id,
    this.nameZh,
    this.nameEn,
    this.category,
    this.cardId,
  });

  Transaction.fromJson(dynamic json) {
    userIcon = json['userIcon'];
    moneyActionName = json['moneyActionName'];
    moneyAmount = (json['moneyAmount'] as num?)?.toDouble();
    time = json['time'];
    id = json['id'] as String?;
    nameZh = json['nameZh'] as String?;
    nameEn = json['nameEn'] as String?;
    category = json['category'] as String?;
    cardId = json['cardId'] as String?;
  }

  String? userIcon;
  String? moneyActionName;
  double? moneyAmount;
  String? time;
  String? id;
  String? nameZh;
  String? nameEn;
  String? category;
  String? cardId;

  Transaction copyWith({
    String? id,
    String? nameZh,
    String? nameEn,
    String? category,
    String? cardId,
    String? userIcon,
    String? moneyActionName,
    double? moneyAmount,
    String? time,
  }) => Transaction(
    id: id ?? this.id,
    nameZh: nameZh ?? this.nameZh,
    nameEn: nameEn ?? this.nameEn,
    category: category ?? this.category,
    cardId: cardId ?? this.cardId,
    userIcon: userIcon ?? this.userIcon,
    moneyActionName: moneyActionName ?? this.moneyActionName,
    moneyAmount: moneyAmount ?? this.moneyAmount,
    time: time ?? this.time,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nameZh'] = nameZh;
    map['nameEn'] = nameEn;
    map['category'] = category;
    map['cardId'] = cardId;
    map['userIcon'] = userIcon;
    map['moneyActionName'] = moneyActionName;
    map['moneyAmount'] = moneyAmount;
    map['time'] = time;
    return map;
  }
}
