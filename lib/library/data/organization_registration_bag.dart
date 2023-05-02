import 'package:hive/hive.dart';

import 'organization.dart';
import 'project.dart';
import 'project_position.dart';
import 'settings_model.dart';
import 'user.dart';
part 'organization_registration_bag.g.dart';

@HiveType(typeId: 21)
class OrganizationRegistrationBag extends HiveObject {
  @HiveField(0)
  Organization? organization;
  @HiveField(1)
  ProjectPosition? projectPosition;
  @HiveField(2)
  User? user;
  @HiveField(3)
  String? date;
  @HiveField(4)
  Project? project;
  @HiveField(5)
  double? latitude;
  @HiveField(6)
  double? longitude;
  @HiveField(7)
  SettingsModel? settings;

  OrganizationRegistrationBag(
      {required this.organization,
      required this.projectPosition,
      required this.user,
      this.settings,
      required this.project,
      required this.date,
      required this.latitude,
      required this.longitude});

  OrganizationRegistrationBag.fromJson(Map data) {
    latitude = data['latitude'];
    longitude = data['longitude'];
    if (data['user'] != null) {
      user = User.fromJson(data['user']);
    }

    date = data['date'];
    if (data['project'] != null) {
      project = Project.fromJson(data['project']);
    }
    if (data['projectPosition'] != null) {
      projectPosition = ProjectPosition.fromJson(data['projectPosition']);
    }
    if (data['organization'] != null) {
      organization = Organization.fromJson(data['organization']);
    }
    if (data['settings'] != null) {
      settings = SettingsModel.fromJson(data['settings']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'organization': organization == null ? null : organization!.toJson(),
      'projectPosition':
          projectPosition == null ? null : projectPosition!.toJson(),
      'user': user == null ? null : user!.toJson(),
      'settings': settings == null ? null : settings!.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'project': project == null ? null : project!.toJson(),
    };
    return map;
  }
}
