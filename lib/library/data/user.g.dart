// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 11;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      name: fields[0] as String?,
      email: fields[2] as String?,
      userId: fields[1] as String?,
      cellphone: fields[4] as String?,
      created: fields[5] as String?,
      userType: fields[6] as String?,
      gender: fields[3] as String?,
      organizationName: fields[7] as String?,
      organizationId: fields[10] as String?,
      countryId: fields[9] as String?,
      active: fields[14] as int?,
      imageUrl: fields[15] as String?,
      thumbnailUrl: fields[16] as String?,
      translatedMessage: fields[17] as String?,
      translatedTitle: fields[18] as String?,
      position: fields[11] as Position?,
      fcmRegistration: fields[8] as String?,
      password: fields[12] as String?,
    )..updated = fields[13] as String?;
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.cellphone)
      ..writeByte(5)
      ..write(obj.created)
      ..writeByte(6)
      ..write(obj.userType)
      ..writeByte(7)
      ..write(obj.organizationName)
      ..writeByte(8)
      ..write(obj.fcmRegistration)
      ..writeByte(9)
      ..write(obj.countryId)
      ..writeByte(10)
      ..write(obj.organizationId)
      ..writeByte(11)
      ..write(obj.position)
      ..writeByte(12)
      ..write(obj.password)
      ..writeByte(13)
      ..write(obj.updated)
      ..writeByte(14)
      ..write(obj.active)
      ..writeByte(15)
      ..write(obj.imageUrl)
      ..writeByte(16)
      ..write(obj.thumbnailUrl)
      ..writeByte(17)
      ..write(obj.translatedMessage)
      ..writeByte(18)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
