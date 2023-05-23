

class CancelPaymentRequest {
  CancelPaymentRequest({
      this.paymentInitiationRequestId, 
      this.reason,});

  CancelPaymentRequest.fromJson(dynamic json) {
    paymentInitiationRequestId = json['paymentInitiationRequestId'];
    reason = json['reason'];
  }
  String? paymentInitiationRequestId;
  String? reason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['paymentInitiationRequestId'] = paymentInitiationRequestId;
    map['reason'] = reason;
    return map;
  }

}
