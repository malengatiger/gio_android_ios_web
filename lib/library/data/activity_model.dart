import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/project_polygon.dart';
import 'package:geo_monitor/library/data/project_position.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:hive/hive.dart';

import 'activity_type_enum.dart';
import 'audio.dart';
import 'geofence_event.dart';
import 'location_request.dart';
import 'location_response.dart';
import 'org_message.dart';
import 'user.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 60)
class ActivityModel extends HiveObject {
  @HiveField(0)
  String? activityModelId;

  @HiveField(1)
  ActivityType? activityType;

  @HiveField(2)
  String? date;

  @HiveField(3)
  String? userId;
  @HiveField(4)
  String? userName;
  @HiveField(5)
  String? projectId;
  @HiveField(6)
  String? projectName;
// String thumbnailUrl, url;
  @HiveField(7)
  String? organizationName;
  @HiveField(8)
  String? organizationId;

  @HiveField(9)
  Photo? photo;
  @HiveField(10)
  Video? video;
  @HiveField(11)
  Audio? audio;
  @HiveField(12)
  User? user;
  @HiveField(13)
  Project? project;
  @HiveField(14)
  ProjectPosition? projectPosition;
  @HiveField(15)
  ProjectPolygon? projectPolygon;
  @HiveField(16)
  OrgMessage? orgMessage;
  @HiveField(17)
  GeofenceEvent? geofenceEvent;
  @HiveField(18)
  LocationRequest? locationRequest;
  @HiveField(19)
  LocationResponse? locationResponse;
  @HiveField(20)
  String? userThumbnailUrl;
  @HiveField(21)
  String? userType;
  @HiveField(22)
  String? translatedUserType;

  ActivityModel({
    required this.activityModelId,
    required this.activityType,
    required this.date,
    required this.userId,
    required this.userName,
    required this.projectId,
    required this.projectName,
    required this.organizationId,
    required this.organizationName,
    required this.locationResponse,
    required this.video,
    required this.project,
    required this.photo,
    required this.projectPosition,
    required this.audio,
    required this.projectPolygon,
    required this.locationRequest,
    required this.user,
    required this.geofenceEvent,
    required this.orgMessage,
    required this.userType,
    required this.translatedUserType,
    required this.userThumbnailUrl,
  });

  ActivityModel.fromJson(Map data) {
    var xType = data['activityType'];

    if (xType != null) {
      activityType = getActivityType(xType);
    }

    date = data['date'];
    activityModelId = data['activityModelId'];

    userId = data['userId'];

    userName = data['userName'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    userThumbnailUrl = data['userThumbnailUrl'];
    if (data[''] != null) {}
    if (data['locationResponse'] != null) {
      locationResponse = LocationResponse.fromJson(data['locationResponse']);
    }
    if (data['video'] != null) {
      video = Video.fromJson(data['video']);
    }
    if (data['project'] != null) {
      project = Project.fromJson(data['project']);
    }
    if (data['photo'] != null) {
      photo = Photo.fromJson(data['photo']);
    }
    if (data['projectPosition'] != null) {
      projectPosition = ProjectPosition.fromJson(data['projectPosition']);
    }
    if (data['audio'] != null) {
      audio = Audio.fromJson(data['audio']);
    }
    if (data['projectPolygon'] != null) {
      projectPolygon = ProjectPolygon.fromJson(data['projectPolygon']);
    }
    if (data['locationRequest'] != null) {
      locationRequest = LocationRequest.fromJson(data['locationRequest']);
    }
    if (data['user'] != null) {
      user = User.fromJson(data['user']);
    }
    if (data['geofenceEvent'] != null) {
      geofenceEvent = GeofenceEvent.fromJson(data['geofenceEvent']);
    }
    if (data['orgMessage'] != null) {
      orgMessage = OrgMessage.fromJson(data['orgMessage']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'activityModelId': activityModelId,
      'date': date,
      'userId': userId,
      'userName': userName,
      'projectId': projectId,
      'projectName': projectName,
      'userThumbnailUrl': userThumbnailUrl,
      'activityType':
          activityType == null ? null : activityType!.toShortString(),
      'organizationId': organizationId,
      'organizationName': organizationName,
      'locationResponse':
          locationResponse == null ? null : locationResponse!.toJson(),
      'video': video == null ? null : video!.toJson(),
      'project': project == null ? null : project!.toJson(),
      'photo': photo == null ? null : photo!.toJson(),
      'projectPosition':
          projectPosition == null ? null : projectPosition!.toJson(),
      'audio': audio == null ? null : audio!.toJson(),
      'projectPolygon':
          projectPolygon == null ? null : projectPolygon!.toJson(),
      'locationRequest':
          locationRequest == null ? null : locationRequest!.toJson(),
      'user': user == null ? null : user!.toJson(),
      'geofenceEvent': geofenceEvent == null ? null : geofenceEvent!.toJson(),
      'orgMessage': orgMessage == null ? null : orgMessage!.toJson(),
    };
    return map;
  }
}
