import 'package:hive/hive.dart';

part 'project_summary.g.dart';

@HiveType(typeId: 65)
class ProjectSummary extends HiveObject {
  @HiveField(0)
  int? photos;
  @HiveField(1)
  int? videos;
  @HiveField(2)
  int? audios;
  @HiveField(3)
  String? date;
  @HiveField(4)
  int? schedules;
  @HiveField(5)
  String? organizationId;
  @HiveField(6)
  int? calculatedHourly;
  @HiveField(7)
  String? organizationName;
  @HiveField(8)
  int? projectPositions;
  @HiveField(9)
  int? projectPolygons;
  @HiveField(10)
  String? projectId;
  @HiveField(11)
  String? projectName;

  @HiveField(12)
  int? day;
  @HiveField(13)
  int? hour;
  @HiveField(14)
  String? startDate;

  @HiveField(15)
  String? endDate;
  @HiveField(16)
  String? batchId;

  ProjectSummary({
    required this.photos,
    required this.audios,
    required this.date,
    required this.calculatedHourly,
    required this.projectPositions,
    required this.projectPolygons,
    required this.projectId,
    required this.videos,
    required this.schedules,
    required this.organizationId,
    required this.projectName,
    required this.organizationName,
    required this.day,
    required this.hour,
    required this.startDate,
    required this.endDate,
    required this.batchId,
  });

  ProjectSummary.fromJson(Map data) {
    organizationId = data['organizationId'];
    projectPositions = data['projectPositions'];
    photos = data['photos'];
    videos = data['videos'];
    audios = data['audios'];

    day = data['day'];
    hour = data['hour'];

    endDate = data['endDate'];
    startDate = data['startDate'];
    batchId = data['batchId'];

    date = data['date'];
    organizationId = data['organizationId'];
    calculatedHourly = data['calculatedHourly'];
    schedules = data['schedules'];
    projectPolygons = data['projectPolygons'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    organizationName = data['organizationName'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'photos': photos,
      'organizationId': organizationId,
      'audios': audios,
      'date': date,
      'day': day,
      'hour': hour,
      'batchId': batchId,
      'startDate': startDate,
      'endDate': endDate,
      'calculatedHourly': calculatedHourly,
      'organizationName': organizationName,
      'schedules': schedules,
      'projectPolygons': projectPolygons,
      'projectId': projectId,
      'projectName': projectName,
      'videos': videos,
      'projectPositions': projectPositions,
    };
    return map;
  }
}
