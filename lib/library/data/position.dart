import 'package:hive/hive.dart';


part 'position.g.dart';

@HiveType(typeId: 16)
class Position extends HiveObject {

  @HiveField(0)
  String? type = 'Point';
  @HiveField(1)
  List coordinates = [];
  Position({
    required this.coordinates,
    required this.type,
  });

  Position.fromJson(Map data) {
    coordinates = [];
    if (data['coordinates'] != null) {
      List list = data['coordinates'];
      for (var value in list) {
        coordinates.add(value);
      }
    }
    type = data['type'];
  }
  Map<String, dynamic> toJson() {
    var m = [];
    for (var element in coordinates) {
      m.add(element);
    }
    Map<String, dynamic> map = {
      'type': type,
      'coordinates': m,
    };
    return map;
  }
}
