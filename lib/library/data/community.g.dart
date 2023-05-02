// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunityAdapter extends TypeAdapter<Community> {
  @override
  final int typeId = 13;

  @override
  Community read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Community(
      name: fields[0] as String?,
      countryId: fields[1] as String?,
      email: fields[3] as String?,
      countryName: fields[4] as String?,
      polygon: (fields[8] as List?)?.cast<Position>(),
      created: fields[5] as String?,
      population: fields[6] as int?,
      nearestCities: (fields[12] as List?)?.cast<City>(),
      communityId: fields[2] as String?,
    )
      ..photoUrls = (fields[9] as List?)?.cast<Photo>()
      ..videoUrls = (fields[10] as List?)?.cast<Video>()
      ..ratings = (fields[11] as List?)?.cast<RatingContent>();
  }

  @override
  void write(BinaryWriter writer, Community obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.countryId)
      ..writeByte(2)
      ..write(obj.communityId)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.countryName)
      ..writeByte(5)
      ..write(obj.created)
      ..writeByte(6)
      ..write(obj.population)
      ..writeByte(8)
      ..write(obj.polygon)
      ..writeByte(9)
      ..write(obj.photoUrls)
      ..writeByte(10)
      ..write(obj.videoUrls)
      ..writeByte(11)
      ..write(obj.ratings)
      ..writeByte(12)
      ..write(obj.nearestCities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
