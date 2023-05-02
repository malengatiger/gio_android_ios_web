import 'package:hive/hive.dart';

part 'field_monitor_schedule.g.dart';

@HiveType(typeId: 2)
class FieldMonitorSchedule extends HiveObject {
  @HiveField(0)
  String? fieldMonitorScheduleId;
  @HiveField(1)
  String? fieldMonitorId;
  @HiveField(2)
  String? adminId;
  @HiveField(3)
  String? organizationId;
  @HiveField(4)
  String? projectId;
  @HiveField(5)
  String? projectName;
  @HiveField(6)
  String? date;
  @HiveField(7)
  String? organizationName;
  @HiveField(8)
  int? perDay;
  @HiveField(9)
  int? perWeek;
  @HiveField(10)
  int? perMonth;
  @HiveField(11)
  String? userId;

  FieldMonitorSchedule(
      {required this.fieldMonitorId,
      required this.adminId,
      required this.projectId,
      required this.date,
      required this.fieldMonitorScheduleId,
      this.perDay,
      this.perWeek,
      this.perMonth,
      this.projectName,
      this.organizationName,
      required this.userId,
      required this.organizationId});

  FieldMonitorSchedule.fromJson(Map data) {
    fieldMonitorId = data['fieldMonitorId'];
    userId = data['userId'];

    fieldMonitorScheduleId = data['fieldMonitorScheduleId'];
    adminId = data['adminId'];
    organizationId = data['organizationId'];
    projectId = data['projectId'];
    projectName = data['projectName'];
    organizationName = data['organizationName'];
    perDay = data['perDay'];
    perWeek = data['perWeek'];
    perMonth = data['perMonth'];
    date = data['date'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'fieldMonitorId': fieldMonitorId,
      'userId': userId,
      'fieldMonitorScheduleId': fieldMonitorScheduleId,
      'date': date,
      'adminId': adminId,
      'organizationId': organizationId,
      'projectId': projectId,
      'projectName': projectName,
      'organizationName': organizationName,
      'perDay': perDay,
      'perWeek': perWeek,
      'perMonth': perMonth,
    };
    return map;
  }
}
