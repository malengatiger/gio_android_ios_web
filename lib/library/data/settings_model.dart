import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 30)
class SettingsModel {
  @HiveField(0)
  int? distanceFromProject;
  @HiveField(1)
  int? photoSize;
  @HiveField(2)
  int? maxVideoLengthInSeconds;
  @HiveField(3)
  int? maxAudioLengthInMinutes;
  @HiveField(4)
  int? themeIndex;
  @HiveField(5)
  String? settingsId;
  @HiveField(6)
  String? created;
  @HiveField(7)
  String? organizationId;
  @HiveField(8)
  String? projectId;
  @HiveField(9)
  int? activityStreamHours;
  @HiveField(10)
  int? numberOfDays;
  @HiveField(11)
  String? locale = "en";
  @HiveField(12)
  String? translatedMessage;

  @HiveField(13)
  String? translatedTitle;

  SettingsModel(
      {required this.distanceFromProject,
      required this.photoSize,
      required this.maxVideoLengthInSeconds,
      required this.maxAudioLengthInMinutes,
      required this.themeIndex,
      required this.settingsId,
      required this.created,
      required this.organizationId,
      required this.projectId,
      required this.numberOfDays,
      required this.locale,
      required this.translatedMessage,
      required this.translatedTitle,
      required this.activityStreamHours});

  SettingsModel.fromJson(Map data) {
    // pp('🌀🌀🌀🌀 data json from server $data');
    distanceFromProject = data['distanceFromProject'];
    photoSize = data['photoSize'];
    settingsId = data['settingsId'];
    created = data['created'];
    activityStreamHours = data['activityStreamHours'];
    organizationId = data['organizationId'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];
    if (data['locale'] != null) {
      locale = data['locale'];
    } else {
      locale = 'en';
    }

    if (data['numberOfDays'] != null) {
      numberOfDays = data['numberOfDays'];
    } else {
      numberOfDays = 7;
    }
    if (data['projectId'] != null) {
      projectId = data['projectId'];
    }

    themeIndex = 0;
    if (data['themeIndex'] != null) {
      themeIndex = data['themeIndex'];
    }
    if (data['maxVideoLengthInSeconds'] == null) {
      maxVideoLengthInSeconds = 15;
    } else {
      maxVideoLengthInSeconds = data['maxVideoLengthInSeconds'];
    }
    maxAudioLengthInMinutes = data['maxAudioLengthInMinutes'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'distanceFromProject': distanceFromProject,
      'photoSize': photoSize,
      'projectId': projectId,
      'organizationId': organizationId,
      'created': created,
      'numberOfDays': numberOfDays ?? 7,
      'activityStreamHours': activityStreamHours,
      'settingsId': settingsId,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'themeIndex': themeIndex,
      'locale': locale,
      'maxVideoLengthInSeconds': maxVideoLengthInSeconds,
      'maxAudioLengthInMinutes': maxAudioLengthInMinutes,
    };
    return map;
  }
}
