// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_error.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppErrorAdapter extends TypeAdapter<AppError> {
  @override
  final int typeId = 66;

  @override
  AppError read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppError(
      errorMessage: fields[0] as String?,
      model: fields[2] as String?,
      created: fields[3] as String?,
      userId: fields[5] as String?,
      userName: fields[7] as String?,
      errorPosition: fields[8] as Position?,
      iosName: fields[9] as String?,
      versionCodeName: fields[10] as String?,
      manufacturer: fields[1] as String?,
      brand: fields[4] as String?,
      organizationId: fields[6] as String?,
      baseOS: fields[11] as String?,
      deviceType: fields[12] as String?,
      userUrl: fields[14] as String?,
      uploadedDate: fields[15] as String?,
      iosSystemName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppError obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.errorMessage)
      ..writeByte(1)
      ..write(obj.manufacturer)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.organizationId)
      ..writeByte(7)
      ..write(obj.userName)
      ..writeByte(8)
      ..write(obj.errorPosition)
      ..writeByte(9)
      ..write(obj.iosName)
      ..writeByte(10)
      ..write(obj.versionCodeName)
      ..writeByte(11)
      ..write(obj.baseOS)
      ..writeByte(12)
      ..write(obj.deviceType)
      ..writeByte(13)
      ..write(obj.iosSystemName)
      ..writeByte(14)
      ..write(obj.userUrl)
      ..writeByte(15)
      ..write(obj.uploadedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppErrorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
