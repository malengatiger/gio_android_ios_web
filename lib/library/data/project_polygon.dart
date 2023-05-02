import 'package:hive/hive.dart';

import '../data/position.dart';
import 'city.dart';

part 'project_polygon.g.dart';

@HiveType(typeId: 19)
class ProjectPolygon extends HiveObject {
  @HiveField(0)
  String? projectName;

  @HiveField(1)
  String? projectId;

  @HiveField(2)
  String? created;

  @HiveField(3)
  String? projectPolygonId;

  @HiveField(4)
  String? organizationId;

  @HiveField(5)
  List<Position> positions = <Position>[];

  @HiveField(6)
  List<City> nearestCities = <City>[];
  @HiveField(7)
  String? name;

  @HiveField(8)
  String? userId;
  @HiveField(9)
  String? userName;

  @HiveField(10)
  String? translatedMessage;

  @HiveField(11)
  String? translatedTitle;

  ProjectPolygon(
      {required this.projectName,
      required this.projectPolygonId,
      required this.created,
      required this.positions,
      required this.nearestCities,
      required this.organizationId,
      this.name,
        required this.translatedMessage,
        required this.translatedTitle,
      required this.projectId,
      required this.userId,
      required this.userName});

  ProjectPolygon.fromJson(Map data) {
    projectName = data['projectName'];
    projectId = data['projectId'];
    userId = data['userId'];
    userName = data['userName'];
    projectPolygonId = data['projectPolygonId'];
    name = data['name'];
    organizationId = data['organizationId'];
    created = data['created'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];

    positions = [];
    if (data['positions'] != null) {
      List list = data['positions'];
      for (var value in list) {
        var position = Position.fromJson(value);
        positions.add(position);
      }
    }

    nearestCities = [];
    if (data['nearestCities'] != null) {
      List list = data['nearestCities'];
      for (var c in list) {
        nearestCities.add(City.fromJson(c));
      }
    }
  }

  Map<String, dynamic> toJson() {
    var cityList = [];
    for (var c in nearestCities) {
      cityList.add(c.toJson());
    }
    var positionList = [];
    for (var c in positions) {
      positionList.add(c.toJson());
    }
    Map<String, dynamic> map = {
      'projectName': projectName,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'organizationId': organizationId,
      'projectPolygonId': projectPolygonId,
      'created': created,
      'name': name,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'positions': positionList,
      'nearestCities': cityList,
    };
    return map;
  }
}
