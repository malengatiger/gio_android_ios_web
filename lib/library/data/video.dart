import 'package:hive/hive.dart';

import '../data/position.dart';

part 'video.g.dart';

@HiveType(typeId: 10)
class Video extends HiveObject {
  @HiveField(0)
  String? url;
  @HiveField(1)
  String? caption;
  @HiveField(2)
  String? created;
  @HiveField(3)
  String? thumbnailUrl;
  @HiveField(4)
  String? videoId;
  @HiveField(5)
  String? projectPositionId;
  @HiveField(6)
  String? userId;
  @HiveField(7)
  String? userName;
  @HiveField(8)
  String? organizationId;
  @HiveField(9)
  Position? projectPosition;
  @HiveField(10)
  double? distanceFromProjectPosition;
  @HiveField(11)
  String? projectId;
  @HiveField(12)
  String? projectName;
  @HiveField(13)
  String? projectPolygonId;
  @HiveField(14)
  int? durationInSeconds;

  @HiveField(15)
  double? size;
  @HiveField(16)
  String? userUrl;
  @HiveField(17)
  String? translatedMessage;

  @HiveField(18)
  String? translatedTitle;

  Video(
      {required this.url,
      this.caption,
      this.projectPositionId,
      this.projectPolygonId,
      required this.created,
      required this.userId,
      required this.userName,
      required this.projectPosition,
      required this.distanceFromProjectPosition,
      required this.projectId,
      required this.thumbnailUrl,
      required this.videoId,
      required this.durationInSeconds,
      required this.organizationId,
      required this.size,
        required this.translatedMessage,
        required this.translatedTitle,
      required this.userUrl,
      required this.projectName}); // Video({required this.url, this.userId, required this.created});

  Video.fromJson(Map data) {
    url = data['url'];
    projectPositionId = data['projectPositionId'];
    projectPolygonId = data['projectPolygonId'];
    caption = data['caption'];
    created = data['created'];
    userId = data['userId'];
    userUrl = data['userUrl'];
    organizationId = data['organizationId'];
    durationInSeconds = data['durationInSeconds'];
    thumbnailUrl = data['thumbnailUrl'];
    videoId = data['videoId'];
    userName = data['userName'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];
    if (data['size'] != null) {
      size = data['size'];
    } else {
      size = 0.0;
    }
    distanceFromProjectPosition = data['distanceFromProjectPosition'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    if (data['projectPosition'] != null) {
      projectPosition = Position.fromJson(data['projectPosition']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'url': url,
      'projectPositionId': projectPositionId,
      'projectPolygonId': projectPolygonId,
      'caption': caption,
      'created': created,
      'userUrl': userUrl,
      'userId': userId,
      'videoId': videoId,
      'organizationId': organizationId,
      'durationInSeconds': durationInSeconds,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'userName': userName,
      'thumbnailUrl': thumbnailUrl,
      'distanceFromProjectPosition': distanceFromProjectPosition,
      'projectId': projectId,
      'projectName': projectName,
      'size': size ?? 0.0,
      'projectPosition':
          projectPosition == null ? null : projectPosition!.toJson()
    };
    return map;
  }
}
