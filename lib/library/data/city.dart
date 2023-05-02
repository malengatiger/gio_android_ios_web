import 'package:geo_monitor/library/data/position.dart';
import 'package:hive/hive.dart';
part 'city.g.dart';

@HiveType(typeId: 7)
class City extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? countryId;
  @HiveField(2)
  String? country;
  @HiveField(3)
  String? province;
  @HiveField(4)
  String? cityId;
  @HiveField(5)
  String? created;
  @HiveField(6)
  Position? cityLocation;

  City(
      {required this.name,
      required this.countryId,
      required this.province,
      required this.country,
      required this.cityLocation,
      required this.created});

  City.fromJson(Map data) {
    name = data['name'];
    countryId = data['countryId'];
    country = data['country'];
    province = data['province'];
    created = data['created'];
    cityId = data['cityId'];
    if (data['cityLocation'] != null) {
      cityLocation = Position.fromJson( data['cityLocation']);
    }

  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'countryId': countryId,
      'country': country,
      'province': province,
      'cityId': cityId,
      'created': created,
      'cityLocation': cityLocation == null? null : cityLocation!.toJson(),
    };
    return map;
  }
}
