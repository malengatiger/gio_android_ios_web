// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_packed.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyPackedAdapter extends TypeAdapter<DailyPacked> {
  @override
  final int typeId = 40;

  @override
  DailyPacked read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyPacked(
      weatherCode: fields[0] as int?,
      maxTemperature: fields[2] as double?,
      time: fields[3] as String?,
      sunrise: fields[6] as String?,
      sunset: fields[7] as String?,
      precipitationSum: fields[8] as double?,
      minTemperature: fields[1] as double?,
      apparentMinTemp: fields[4] as double?,
      apparentMaxTemp: fields[5] as double?,
      evapoTranspiration: fields[15] as double?,
      precipitationHours: fields[11] as double?,
      rainSum: fields[9] as double?,
      shortwaveRadiation: fields[14] as double?,
      showersSum: fields[10] as double?,
      windDirectionDominant: fields[13] as double?,
      windSpeedMax: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyPacked obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.weatherCode)
      ..writeByte(1)
      ..write(obj.minTemperature)
      ..writeByte(2)
      ..write(obj.maxTemperature)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.apparentMinTemp)
      ..writeByte(5)
      ..write(obj.apparentMaxTemp)
      ..writeByte(6)
      ..write(obj.sunrise)
      ..writeByte(7)
      ..write(obj.sunset)
      ..writeByte(8)
      ..write(obj.precipitationSum)
      ..writeByte(9)
      ..write(obj.rainSum)
      ..writeByte(10)
      ..write(obj.showersSum)
      ..writeByte(11)
      ..write(obj.precipitationHours)
      ..writeByte(12)
      ..write(obj.windSpeedMax)
      ..writeByte(13)
      ..write(obj.windDirectionDominant)
      ..writeByte(14)
      ..write(obj.shortwaveRadiation)
      ..writeByte(15)
      ..write(obj.evapoTranspiration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPackedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
