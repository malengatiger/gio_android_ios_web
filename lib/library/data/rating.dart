import 'package:hive/hive.dart';
import '../data/position.dart';
import '../functions.dart';
part 'rating.g.dart';

@HiveType(typeId: 26)
class Rating extends HiveObject {
  @HiveField(0)
  String? remarks;
  @HiveField(2)
  String? created;
  @HiveField(3)
  String? audioId;
  @HiveField(4)
  String? photoId;
  @HiveField(5)
  String? userId;
  @HiveField(6)
  String? userName;
  @HiveField(7)
  String? organizationId;
  @HiveField(8)
  int? ratingCode;
  @HiveField(9)
  String? projectId;
  @HiveField(10)
  String? projectName;
  @HiveField(11)
  String? videoId;
  @HiveField(12)
  String? ratingId;
  @HiveField(13)
  Position? position;

  Rating(
      {required this.remarks,
        this.photoId,
        this.videoId,
        required this.created,
        required this.userId,
        required this.userName,
        required this.ratingCode,
        required this.projectId,
        required this.audioId,
        required this.position,
        required this.ratingId,
        required this.organizationId,
        required this.projectName}); // Rating({required this.remarks, this.userId, required this.created});

  Rating.fromJson(Map data) {
    pp('data from server : $data');
    remarks = data['remarks'];
    photoId = data['photoId'];
    videoId = data['videoId'];
    ratingId = data['ratingId'];
    created = data['created'];
    userId = data['userId'];
    organizationId = data['organizationId'];
    audioId = data['audioId'];
    userName = data['userName'];
    ratingCode = data['ratingCode'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    ratingId = data['ratingId'];
    pp('🌎🌎🌎🌎🌎🌎 do we get here? 1');
    if (data['position'] != null) {
      position = Position.fromJson(data);
    }
    pp('🌎🌎🌎🌎🌎🌎 do we get here? 2 ');
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'remarks': remarks,
      'photoId': photoId,
      'videoId': videoId,
      'created': created,
      'ratingId': ratingId,
      'userId': userId,
      'audioId': audioId,
      'organizationId': organizationId,
      'userName': userName,
      'ratingCode': ratingCode,
      'projectId': projectId,
      'projectName': projectName,
      'position': position == null? null: position!.toJson(),
    };
    return map;
  }
}