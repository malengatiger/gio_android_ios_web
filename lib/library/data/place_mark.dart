import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
part 'place_mark.g.dart';

@HiveType(typeId: 17)
class PlaceMark extends HiveObject  {
  @HiveField(0)
  String? administrativeArea;
  @HiveField(1)
  String? subAdministrativeArea;
  @HiveField(2)
  String? locality;
  @HiveField(3)
  String? subLocality;
  @HiveField(4)
  String? thoroughfare;
  @HiveField(5)
  String? subThoroughfare;
  @HiveField(6)
  String? name;
  @HiveField(7)
  String? street;
  @HiveField(8)
  String? country;
  @HiveField(9)
  String? isoCountryCode;
  @HiveField(10)
  String? postalCode;

  PlaceMark(
      {required this.administrativeArea,
      required this.subAdministrativeArea,
      required this.subLocality,
      required this.locality,
      required this.name,
      required this.subThoroughfare,
      required this.street,
      required this.country,
      required this.isoCountryCode,
      required this.postalCode,
      required this.thoroughfare});

  PlaceMark.fromJson(Map data) {
    administrativeArea = data['administrativeArea'];
    subAdministrativeArea = data['subAdministrativeArea'];
    locality = data['locality'];
    subLocality = data['subLocality'];
    locality = data['locality'];
    subThoroughfare = data['subThoroughfare'];
    thoroughfare = data['thoroughfare'];
    name = data['name'];

    street = data['street'];
    country = data['country'];
    isoCountryCode = data['isoCountryCode'];
    postalCode = data['postalCode'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'administrativeArea': administrativeArea,
      'subAdministrativeArea': subAdministrativeArea,
      'locality': locality,
      'subLocality': subLocality,
      'thoroughfare': thoroughfare,
      'subThoroughfare': subThoroughfare,
      'name': name,
      'street': street,
      'country': country,
      'isoCountryCode': isoCountryCode,
      'postalCode': postalCode,
    };
    return map;
  }
  static PlaceMark getPlaceMark({required Placemark placemark}) {
    var pm = PlaceMark(administrativeArea: placemark.administrativeArea!,
        subAdministrativeArea: placemark.subAdministrativeArea,
        subLocality: placemark.subLocality,
        locality: placemark.locality,
        name: placemark.name,
        subThoroughfare: placemark.subThoroughfare,
        street: placemark.street,
        country: placemark.country,
        isoCountryCode: placemark.isoCountryCode,
        postalCode: placemark.postalCode,
        thoroughfare: placemark.thoroughfare);

    return pm;
  }
}
