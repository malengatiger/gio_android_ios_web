import 'package:hive/hive.dart';
import '../data/position.dart';

part 'hourly_packed.g.dart';
/*
String time;
    double temperature;
    int relativeHumidity;
    double rain;
    double showers;
    double pressure, surfacePressure;
    int cloudCover;
    double windSpeed;
 */

@HiveType(typeId: 41)
class HourlyPacked extends HiveObject {
  @HiveField(0)
  double? temperature;
  @HiveField(1)
  int? relativeHumidity;
  @HiveField(2)
  double? rain;
  @HiveField(3)
  String? time;
  @HiveField(4)
  double? showers;
  @HiveField(5)
  double? pressure;
  @HiveField(6)
  double? surfacePressure;
  @HiveField(7)
  int? cloudCover;
  @HiveField(8)
  double? windSpeed;

  HourlyPacked(
      {required this.temperature,
      required this.rain,
      required this.time,
      required this.surfacePressure,
      required this.cloudCover,
      required this.windSpeed,
      required this.relativeHumidity,
      required this.showers,
      required this.pressure,
        });

  HourlyPacked.fromJson(Map data) {

    pressure = data['pressure'];
    temperature = data['temperature'];
    relativeHumidity = data['relativeHumidity'];
    rain = data['rain'];
    time = data['time'];
    surfacePressure = data['surfacePressure'];
    showers = data['showers'];
    cloudCover = data['cloudCover'];
    windSpeed = data['windSpeed'];

  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'temperature': temperature,
      'pressure': pressure,
      'rain': rain,
      'time': time,
      'surfacePressure': surfacePressure,
      'showers': showers,
      'cloudCover': cloudCover,
      'windSpeed': windSpeed,
      'relativeHumidity': relativeHumidity,
          };
    return map;
  }
}
