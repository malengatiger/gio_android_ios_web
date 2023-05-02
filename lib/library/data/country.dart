import 'package:hive/hive.dart';

part 'country.g.dart';

@HiveType(typeId: 1)
class Country extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? countryId;

  @HiveField(2)
  String? countryCode;

  @HiveField(3)
  int population = 0;

  Country(
      {required this.name,
        required this.population,
        required this.countryCode});

  Country.fromJson(Map data) {
    name = data['name'];
    countryId = data['countryId'];
    countryCode = data['countryCode'];
    if (data['population'] != null) {
      population = data['population'];
    } else {
      population = 0;
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'countryId': countryId,
      'countryCode': countryCode,
      'population':  population,
    };
    return map;
  }
}
