import 'package:hive/hive.dart';

import '../data/photo.dart';
import '../data/position.dart';
import '../data/project.dart';
import '../data/video.dart';
part 'failed_bag.g.dart';

@HiveType(typeId: 20)
class FailedBag extends HiveObject {
  @HiveField(0)
  String? filePath;
  @HiveField(1)
  String? thumbnailPath;
  @HiveField(2)
  Project? project;
  @HiveField(3)
  String? projectPositionId;
  @HiveField(4)
  String? projectPolygonId;

  @HiveField(5)
  Position? projectPosition;

  @HiveField(6)
  String? date;
  @HiveField(7)
  Photo? photo;
  @HiveField(8)
  Video? video;

  FailedBag(
      {required this.filePath,
      required this.thumbnailPath,
      this.projectPositionId,
        this.projectPolygonId,
      required this.project,
      required this.projectPosition,
      required this.photo,
      required this.video,
      required this.date});

  FailedBag.fromJson(Map data) {
    filePath = data['filePath'];
    thumbnailPath = data['thumbnailPath'];
    date = data['date'];

    projectPolygonId = data['projectPolygonId'];
    projectPositionId = data['projectPositionId'];

    if (data['project'] != null) {
      project = Project.fromJson(data['project']);
    }
    if (data['photo'] != null) {
      photo = Photo.fromJson(data['photo']);
    }
    if (data['video'] != null) {
      video = Video.fromJson(data['video']);
    }
    if (data['projectPosition'] != null) {
      projectPosition = Position.fromJson(data['projectPosition']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'project': project == null ? null : project!.toJson(),
      'projectPositionId': projectPositionId,
      'projectPolygonId': projectPolygonId,
      'date': date,
      'projectPosition':
          projectPosition == null ? null : projectPosition!.toJson(),
      'photo': photo == null? null: photo!.toJson(),
      'video': video == null? null: video!.toJson(),
    };
    return map;
  }
}
