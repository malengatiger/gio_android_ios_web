// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 61;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.projectAdded;
      case 1:
        return ActivityType.photoAdded;
      case 2:
        return ActivityType.videoAdded;
      case 3:
        return ActivityType.audioAdded;
      case 4:
        return ActivityType.messageAdded;
      case 5:
        return ActivityType.userAddedOrModified;
      case 6:
        return ActivityType.positionAdded;
      case 7:
        return ActivityType.polygonAdded;
      case 8:
        return ActivityType.settingsChanged;
      case 9:
        return ActivityType.geofenceEventAdded;
      case 10:
        return ActivityType.conditionAdded;
      case 11:
        return ActivityType.locationRequest;
      case 12:
        return ActivityType.locationResponse;
      case 13:
        return ActivityType.kill;
      default:
        return ActivityType.projectAdded;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.projectAdded:
        writer.writeByte(0);
        break;
      case ActivityType.photoAdded:
        writer.writeByte(1);
        break;
      case ActivityType.videoAdded:
        writer.writeByte(2);
        break;
      case ActivityType.audioAdded:
        writer.writeByte(3);
        break;
      case ActivityType.messageAdded:
        writer.writeByte(4);
        break;
      case ActivityType.userAddedOrModified:
        writer.writeByte(5);
        break;
      case ActivityType.positionAdded:
        writer.writeByte(6);
        break;
      case ActivityType.polygonAdded:
        writer.writeByte(7);
        break;
      case ActivityType.settingsChanged:
        writer.writeByte(8);
        break;
      case ActivityType.geofenceEventAdded:
        writer.writeByte(9);
        break;
      case ActivityType.conditionAdded:
        writer.writeByte(10);
        break;
      case ActivityType.locationRequest:
        writer.writeByte(11);
        break;
      case ActivityType.locationResponse:
        writer.writeByte(12);
        break;
      case ActivityType.kill:
        writer.writeByte(13);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
