import 'package:hive/hive.dart';
part 'credit_card.g.dart';

@HiveType(typeId: 22)
class CreditCard extends HiveObject {
  @HiveField(0)
  String? cardNumber;
  @HiveField(1)
  String? expiryDate;
  @HiveField(2)
  String? cardHolderName;
  @HiveField(3)
  String? cardType;

  @HiveField(5)
  String? created;

  CreditCard(
      {required this.cardNumber,
      required this.expiryDate,
      required this.cardType,
      required this.cardHolderName,
      required this.created});

  CreditCard.fromJson(Map data) {
    cardNumber = data['cardNumber'];
    expiryDate = data['expiryDate'];
    cardHolderName = data['cardHolderName'];
    cardType = data['cardType'];
    created = data['created'];

  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cardType': cardType,
      'created': created,
    };
    return map;
  }
}
