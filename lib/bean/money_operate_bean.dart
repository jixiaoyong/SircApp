/// userIcon : ""
/// moneyActionName : ""
/// moneyAmount : -0.2
/// time : "2 mins ago"

class MoneyOperateBean {
  MoneyOperateBean({
    this.userIcon,
    this.moneyActionName,
    this.moneyAmount,
    this.time,
  });

  MoneyOperateBean.fromJson(dynamic json) {
    userIcon = json['userIcon'];
    moneyActionName = json['moneyActionName'];
    moneyAmount = json['moneyAmount'];
    time = json['time'];
  }

  String? userIcon;
  String? moneyActionName;
  double? moneyAmount;
  String? time;

  MoneyOperateBean copyWith({
    String? userIcon,
    String? moneyActionName,
    double? moneyAmount,
    String? time,
  }) =>
      MoneyOperateBean(
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
