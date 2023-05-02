import 'package:hive/hive.dart';

part 'project_assignment.g.dart';


@HiveType(typeId: 38)
class ProjectAssignment extends HiveObject {
  @HiveField(0)
  String? updated;

  @HiveField(1)
  int? active;

  @HiveField(2)
  String? date;

  @HiveField(3)
  String? projectAssignmentId;

  @HiveField(4)
  String? userId;

  @HiveField(5)
  String? organizationId;

  @HiveField(6)
  String? userName;

  @HiveField(7)
  String? projectId;

  @HiveField(8)
  String? projectName;

  @HiveField(9)
  String? adminId;

  @HiveField(10)
  String? adminName;


  ProjectAssignment(
      {required this.updated,
      required this.date,
      required this.userId,
      required this.userName,
      required this.projectId,
      required this.active,
      required this.projectAssignmentId,
      required this.organizationId,
      required this.projectName,
      required this.adminId,
      required this.adminName,});

  ProjectAssignment.fromJson(Map data) {

    updated = data['updated'];
    active = data['active'];
    adminId = data['adminId'];
    adminName = data['adminName'];
    date = data['date'];
    organizationId = data['organizationId'];
    userId = data['userId'];
    projectAssignmentId = data['projectAssignmentId'];
    userName = data['userName'];
    projectId = data['projectId'];
    projectName = data['projectName'];

  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'updated': updated,

      'date': date,
      'adminName': adminName,
      'adminId': adminId,
      'userId': userId,
      'organizationId': organizationId,
      'projectAssignmentId': projectAssignmentId,
      'userName': userName,
      'projectId': projectId,
      'projectName': projectName,
      'active': active,

    };
    return map;
  }
}
