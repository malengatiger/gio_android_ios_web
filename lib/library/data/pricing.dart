
class Pricing {
  String? countryId, date;
  String? countryName;
  double? monthlyPrice, annualPrice;

  Pricing({
    required this.countryId,
    required this.date,
    required this.countryName,
    required this.monthlyPrice,
    this.annualPrice,
  });

  Pricing.fromJson(Map<String, dynamic> json) {
    countryId = json['countryId'] as String?;
    date = json['date'] as String?;
    countryName = json['countryName'] as String?;
    monthlyPrice = json['monthlyPrice'] as double?;
    annualPrice = json['annualPrice'] as double?;
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'countryId': countryId,
        'date': date,
        'countryName': countryName,
        'monthlyPrice': monthlyPrice,
        'annualPrice': annualPrice,
      };
}
