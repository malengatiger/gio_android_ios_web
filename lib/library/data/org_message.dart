
import 'package:hive/hive.dart';

part 'org_message.g.dart';

@HiveType(typeId: 14)
class OrgMessage extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? userId;
  @HiveField(2)
  String? message;
  @HiveField(3)
  String? created;
  @HiveField(4)
  String? organizationId;
  @HiveField(5)
  String? projectId;
  @HiveField(6)
  String? projectName;
  @HiveField(7)
  String? adminId;
  @HiveField(8)
  String? adminName;
  @HiveField(9)
  String? frequency;
  @HiveField(10)
  String? result;
  @HiveField(11)
  String? orgMessageId;

  OrgMessage(
      {required this.name,
        required this.message,
        required this.userId,
        required this.orgMessageId,
        required this.created,
        required this.projectId,
        required this.projectName,
        required this.adminId,
        required this.adminName,
        required this.frequency,
        required this.organizationId});

  OrgMessage.fromJson(Map data) {
    name = data['name'];
    userId = data['userId'];
    orgMessageId = data['orgMessageId'];
    message = data['message'];
    created = data['created'];
    organizationId = data['organizationId'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    adminId = data['adminId'];
    adminName = data['adminName'];
    frequency = data['frequency'];
    result = data['result'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'userId': userId,
      'orgMessageId': orgMessageId,
      'message': message,
      'created': created,
      'organizationId': organizationId,
      'projectId': projectId,
      'projectName': projectName,
      'adminId': adminId,
      'adminName': adminName,
      'frequency': frequency,
      'result': result,
    };
    return map;
  }
}