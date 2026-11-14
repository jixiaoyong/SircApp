class BankCard {
  final String id;
  final String bankName;
  final String cardNumber;
  final String ownerName;
  final String expirationDate;
  final String? cardType;
  final String? cvv;

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard(
    id: json['id'] as String,
    bankName: json['bankName'] as String,
    cardNumber: json['cardNumber'] as String,
    ownerName: json['ownerName'] as String,
    expirationDate: json['expirationDate'] as String,
    cardType: json['cardType'] as String?,
    cvv: json['cvv'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bankName': bankName,
    'cardNumber': cardNumber,
    'ownerName': ownerName,
    'expirationDate': expirationDate,
    if (cardType != null) 'cardType': cardType,
    if (cvv != null) 'cvv': cvv,
  };

  const BankCard({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    required this.ownerName,
    required this.expirationDate,
    this.cardType,
    this.cvv,
  });

  BankCard copyWith({
    String? id,
    String? bankName,
    String? cardNumber,
    String? ownerName,
    String? expirationDate,
    String? cardType,
    String? cvv,
  }) {
    return BankCard(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      ownerName: ownerName ?? this.ownerName,
      expirationDate: expirationDate ?? this.expirationDate,
      cardType: cardType ?? this.cardType,
      cvv: cvv ?? this.cvv,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bankName == other.bankName &&
          cardNumber == other.cardNumber &&
          ownerName == other.ownerName &&
          expirationDate == other.expirationDate &&
          cardType == other.cardType &&
          cvv == other.cvv;

  @override
  int get hashCode =>
      id.hashCode ^
      bankName.hashCode ^
      cardNumber.hashCode ^
      ownerName.hashCode ^
      expirationDate.hashCode ^
      cardType.hashCode ^
      cvv.hashCode;

  @override
  String toString() {
    return 'BankCard(id: $id, bankName: $bankName, cardNumber: $cardNumber, ownerName: $ownerName, expirationDate: $expirationDate, cardType: $cardType)';
  }
}
