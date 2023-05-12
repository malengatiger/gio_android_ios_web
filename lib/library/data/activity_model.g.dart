// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 60;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      activityModelId: fields[0] as String?,
      activityType: fields[1] as ActivityType?,
      date: fields[2] as String?,
      userId: fields[3] as String?,
      userName: fields[4] as String?,
      projectId: fields[5] as String?,
      projectName: fields[6] as String?,
      organizationId: fields[8] as String?,
      organizationName: fields[7] as String?,
      locationResponse: fields[19] as LocationResponse?,
      video: fields[10] as Video?,
      project: fields[13] as Project?,
      photo: fields[9] as Photo?,
      projectPosition: fields[14] as ProjectPosition?,
      audio: fields[11] as Audio?,
      projectPolygon: fields[15] as ProjectPolygon?,
      locationRequest: fields[18] as LocationRequest?,
      user: fields[12] as User?,
      geofenceEvent: fields[17] as GeofenceEvent?,
      orgMessage: fields[16] as OrgMessage?,
      userType: fields[21] as String?,
      translatedUserType: fields[22] as String?,
      settingsModel: fields[23] as SettingsModel?,
      userThumbnailUrl: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.activityModelId)
      ..writeByte(1)
      ..write(obj.activityType)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.projectId)
      ..writeByte(6)
      ..write(obj.projectName)
      ..writeByte(7)
      ..write(obj.organizationName)
      ..writeByte(8)
      ..write(obj.organizationId)
      ..writeByte(9)
      ..write(obj.photo)
      ..writeByte(10)
      ..write(obj.video)
      ..writeByte(11)
      ..write(obj.audio)
      ..writeByte(12)
      ..write(obj.user)
      ..writeByte(13)
      ..write(obj.project)
      ..writeByte(14)
      ..write(obj.projectPosition)
      ..writeByte(15)
      ..write(obj.projectPolygon)
      ..writeByte(16)
      ..write(obj.orgMessage)
      ..writeByte(17)
      ..write(obj.geofenceEvent)
      ..writeByte(18)
      ..write(obj.locationRequest)
      ..writeByte(19)
      ..write(obj.locationResponse)
      ..writeByte(20)
      ..write(obj.userThumbnailUrl)
      ..writeByte(21)
      ..write(obj.userType)
      ..writeByte(22)
      ..write(obj.translatedUserType)
      ..writeByte(23)
      ..write(obj.settingsModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
