import 'package:hive/hive.dart';

part 'activity_type_enum.g.dart';

@HiveType(typeId: 61)
enum ActivityType {
  @HiveField(0)
  projectAdded,
  @HiveField(1)
  photoAdded,
  @HiveField(2)
  videoAdded,
  @HiveField(3)
  audioAdded,
  @HiveField(4)
  messageAdded,
  @HiveField(5)
  userAddedOrModified,
  @HiveField(6)
  positionAdded,
  @HiveField(7)
  polygonAdded,
  @HiveField(8)
  settingsChanged,
  @HiveField(9)
  geofenceEventAdded,
  @HiveField(10)
  conditionAdded,
  @HiveField(11)
  locationRequest,
  @HiveField(12)
  locationResponse,
  @HiveField(13)
  kill,
}

ActivityType getActivityType(String type) {
  switch (type) {
    case "locationRequest":
      return ActivityType.locationRequest;
      break;
    case "locationResponse":
      return ActivityType.locationResponse;
      break;
    case "geofenceEventAdded":
      return ActivityType.geofenceEventAdded;
      break;
    case "userAddedOrModified":
      return ActivityType.userAddedOrModified;
      break;
    case "polygonAdded":
      return ActivityType.polygonAdded;
      break;
    case "positionAdded":
      return ActivityType.positionAdded;
      break;
    case "audioAdded":
      return ActivityType.audioAdded;
      break;
    case "videoAdded":
      return ActivityType.videoAdded;
      break;
    case "photoAdded":
      return ActivityType.photoAdded;
      break;
    case "projectAdded":
      return ActivityType.projectAdded;
      break;
    case "kill":
      return ActivityType.kill;
      break;
    case "conditionAdded":
      return ActivityType.conditionAdded;
      break;
    case "messageAdded":
      return ActivityType.messageAdded;
      break;
    case "settingsChanged":
      return ActivityType.settingsChanged;
      break;
  }
  throw Exception('Invalid activity type enum');
}

extension ParseToString on ActivityType {
  String toShortString() {
    return toString().split('.').last;
  }
}
