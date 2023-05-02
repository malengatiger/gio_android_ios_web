// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_registration_bag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizationRegistrationBagAdapter
    extends TypeAdapter<OrganizationRegistrationBag> {
  @override
  final int typeId = 21;

  @override
  OrganizationRegistrationBag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrganizationRegistrationBag(
      organization: fields[0] as Organization?,
      projectPosition: fields[1] as ProjectPosition?,
      user: fields[2] as User?,
      settings: fields[7] as SettingsModel?,
      project: fields[4] as Project?,
      date: fields[3] as String?,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, OrganizationRegistrationBag obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.organization)
      ..writeByte(1)
      ..write(obj.projectPosition)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.project)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationRegistrationBagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
