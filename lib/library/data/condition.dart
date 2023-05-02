import 'package:hive/hive.dart';
import '../data/position.dart';

part 'condition.g.dart';

@HiveType(typeId: 12)
class Condition extends HiveObject {
  @HiveField(0)
  String? url;
  @HiveField(1)
  String? caption;
  @HiveField(2)
  String? created;
  @HiveField(3)
  String? conditionId;
  @HiveField(4)
  String? projectPositionId;
  @HiveField(5)
  String? userId;
  @HiveField(6)
  String? userName;
  @HiveField(7)
  Position? projectPosition;
  @HiveField(8)
  int? rating;
  @HiveField(9)
  String? projectId;
  @HiveField(10)
  String? projectName;

  Condition(
      {required this.url,
        this.caption,
        required this.created,
        required this.conditionId,
        required this.userId,
        required this.userName,
        required this.projectPosition,
        required this.rating,
        required this.projectPositionId,
        required this.projectId,
        required this.projectName}); // Video({required this.url, this.userId, required this.created});

  Condition.fromJson(Map data) {
    url = data['url'];
    projectPositionId = data['projectPositionId'];
    caption = data['caption'];
    created = data['created'];
    userId = data['userId'];
    conditionId = data['conditionId'];

    userName = data['userName'];
    rating = data['rating'];
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
      'caption': caption,
      'conditionId': conditionId,
      'created': created,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'projectId': projectId,
      'projectName': projectName,
      'projectPosition': projectPosition == null ? null : projectPosition!.toJson()
    };
    return map;
  }
}