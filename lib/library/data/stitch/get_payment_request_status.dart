class GetPaymentRequestStatus {
  GetPaymentRequestStatus({
      this.paymentRequestId,});

  GetPaymentRequestStatus.fromJson(dynamic json) {
    paymentRequestId = json['paymentRequestId'];
  }
  String? paymentRequestId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['paymentRequestId'] = paymentRequestId;
    return map;
  }

}