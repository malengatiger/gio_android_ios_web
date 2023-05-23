class Amount {
  Amount({
      required this.quantity,
      this.currency,});

  Amount.fromJson(dynamic json) {
    quantity = json['quantity'];
    currency = json['currency'];
  }
  int? quantity;
  String? currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['quantity'] = quantity;
    map['currency'] = currency;
    return map;
  }

}