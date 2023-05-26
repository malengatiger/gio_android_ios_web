import 'package:hive/hive.dart';

import '../data/position.dart';

part 'data_counts.g.dart';

@HiveType(typeId: 70)
class DataCounts extends HiveObject {
  @HiveField(0)
  String? projectId;
  @HiveField(1)
  int? projects;
  @HiveField(2)
  int? users;
  @HiveField(3)
  String? created;
  @HiveField(4)
  String? photos;
  @HiveField(5)
  String? userId;
  @HiveField(6)
  String? organizationId;
  @HiveField(7)
  int? videos;

  @HiveField(9)
  int? audios;
  @HiveField(10)
  int? projectPositions;

  @HiveField(11)
  int? projectPolygons;
  @HiveField(12)
  int? fieldMonitorSchedules;

  @HiveField(13)
  int? activities;

  DataCounts(
      {required this.projectId,
      required this.users,
      required this.created,
      required this.userId,
      required this.videos,
      required this.audios,
      required this.projectPositions,
      required this.projects,
      required this.photos,
      required this.organizationId,
      required this.projectPolygons,
      required this.fieldMonitorSchedules,
      required this.activities});

  DataCounts.fromJson(Map data) {
    projectId = data['projectId'];
    projects = data['projects'];
    users = data['users'];
    projectPolygons = data['projectPolygons'];
    fieldMonitorSchedules = data['fieldMonitorSchedules'];
    created = data['created'];
    created = data['created'];
    organizationId = data['organizationId'];
    activities = data['activities'];

    userId = data['userId'];
    photos = data['photos'];
    videos = data['videos'];
    audios = data['audios'];
    projectPositions = data['projectPositions'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'projectId': projectId,
      'activities': activities,
      'users': users,
      'created': created,
      'fieldMonitorSchedules': fieldMonitorSchedules,
      'projectPolygons': projectPolygons,
      'userId': userId,
      'organizationId': organizationId,
      'photos': photos,
      'videos': videos,
      'audios': audios,
      'projectPositions': projectPositions,
      'projects': projects,
    };
    return map;
  }
}
