import 'package:hive/hive.dart';

import '../data/audio.dart';
import '../data/position.dart';
import '../data/project.dart';
part 'failed_audio.g.dart';

@HiveType(typeId: 24)
class FailedAudio extends HiveObject {
  @HiveField(0)
  String? filePath;
  @HiveField(1)
  Project? project;
  @HiveField(2)
  String? projectPositionId;
  @HiveField(3)
  String? projectPolygonId;

  @HiveField(4)
  Position? projectPosition;

  @HiveField(5)
  String? date;

  @HiveField(6)
  Audio? audio;

  FailedAudio(
      {required this.filePath,
      this.projectPositionId,
      required this.project,
      required this.projectPosition, required this.audio,
      this.projectPolygonId, required this.date});

  FailedAudio.fromJson(Map data) {
    filePath = data['filePath'];
    date = data['date'];

    projectPolygonId = data['projectPolygonId'];
    projectPositionId = data['projectPositionId'];

    if (data['project'] != null) {
      project = Project.fromJson(data['project']);
    }
    if (data['audio'] != null) {
      audio = Audio.fromJson(data['audio']);
    }
    if (data['projectPosition'] != null) {
      projectPosition = Position.fromJson(data['projectPosition']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'filePath': filePath,
      'project': project == null ? null : project!.toJson(),
      'projectPositionId': projectPositionId,
      'projectPolygonId': projectPolygonId,
      'date': date,
      'audio': audio == null? null: audio!.toJson(),
      'projectPosition':
          projectPosition == null ? null : projectPosition!.toJson(),
    };
    return map;
  }
}
