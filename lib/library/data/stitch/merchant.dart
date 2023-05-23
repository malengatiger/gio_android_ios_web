class Merchant {
  Merchant({
      this.merchantId, 
      this.merchantName,});

  Merchant.fromJson(dynamic json) {
    merchantId = json['merchantId'];
    merchantName = json['merchantName'];
  }
  String? merchantId;
  String? merchantName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['merchantId'] = merchantId;
    map['merchantName'] = merchantName;
    return map;
  }

}