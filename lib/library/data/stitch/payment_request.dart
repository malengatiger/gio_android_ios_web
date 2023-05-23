import 'Merchant.dart';
import 'amount.dart';

///Payment Initiation Request Statuses
/// The table below describes the different statuses an InstantPay request can have, with the initial status always being PaymentInitiationRequestPending:
///
/// Status	Description
/// PaymentInitiationRequestCompleted	This is a final payment state.
/// PaymentInitiationRequestPending	The user hasn't yet completed the payment initiation request, or they exited the Stitch dialog box before completing the bank selection process.
/// PaymentInitiationRequestCancelled	The payment initiation request was manually cancelled by the client. More information on this can be found here.
/// PaymentInitiationRequestExpired	The payment initiation request has expired while awaiting user interaction. More information on this can be found here.
class GioPaymentRequest {
  GioPaymentRequest({
    this.amount,
    this.payerReference,
    this.beneficiaryReference,
    this.externalReference,
    this.beneficiaryName,
    this.beneficiaryBankId,
    this.beneficiaryAccountNumber,
    this.merchant,
    this.paymentRequestId,
    this.organizationId,
    this.subscriptionId,
    this.date,
  });

  GioPaymentRequest.fromJson(dynamic json) {
    amount = json['amount'] != null ? Amount.fromJson(json['amount']) : null;
    payerReference = json['payerReference'];
    beneficiaryReference = json['beneficiaryReference'];
    externalReference = json['externalReference'];
    beneficiaryName = json['beneficiaryName'];
    beneficiaryBankId = json['beneficiaryBankId'];
    beneficiaryAccountNumber = json['beneficiaryAccountNumber'];
    merchant = json['merchant'];
    paymentRequestId = json['paymentRequestId'];
    organizationId = json['organizationId'];
    subscriptionId = json['subscriptionId'];
    date = json['date'];

  }
  Amount? amount;
  String? payerReference;
  String? beneficiaryReference;
  String? externalReference;
  String? beneficiaryName;
  String? beneficiaryBankId;
  String? beneficiaryAccountNumber;
  String? merchant;
  String? paymentRequestId;
  String? organizationId;
  String? subscriptionId;
  String? date;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (amount != null) {
      map['amount'] = amount!.toJson();
    }
    map['payerReference'] = payerReference;
    map['beneficiaryReference'] = beneficiaryReference;
    map['externalReference'] = externalReference;
    map['beneficiaryName'] = beneficiaryName;
    map['beneficiaryBankId'] = beneficiaryBankId;
    map['beneficiaryAccountNumber'] = beneficiaryAccountNumber;
    map['merchant'] = merchant;
    map['paymentRequestId'] = paymentRequestId;
    map['subscriptionId'] = subscriptionId;
    map['organizationId'] = organizationId;
    map['date'] = date;

    return map;
  }
}
