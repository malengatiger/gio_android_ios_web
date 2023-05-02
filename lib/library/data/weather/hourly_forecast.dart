import 'package:hive/hive.dart';

import 'hourly_units.dart';
part 'hourly_forecast.g.dart';


@HiveType(typeId: 52)
class HourlyForecast {
  @HiveField(0)
  HourlyUnits? hourlyUnits;
  @HiveField(1)
  String? time;
  @HiveField(2)
  double? temperature;
  @HiveField(3)
  int? relativeHumidity;
  @HiveField(4)
  double? rain;
  @HiveField(5)
  double? showers;
  @HiveField(6)
  double? pressure;
  @HiveField(7)
  double? surfacePressure;
  @HiveField(8)
  int? cloudCover;
  @HiveField(9)
  double? windSpeed;
  @HiveField(10)
  String? projectPositionId;
  @HiveField(11)
  String? projectId;
  @HiveField(12)
  String? projectName;
  @HiveField(13)
  String? date;


  HourlyForecast({
    this.hourlyUnits,
    this.time,
    this.temperature,
    this.relativeHumidity,
    this.rain,
    this.showers,
    this.pressure,
    this.surfacePressure,
    this.cloudCover,
    this.windSpeed, this.projectPositionId,
    this.date,
    this.projectId, this.projectName,
  });

  HourlyForecast.fromJson(dynamic json) {
    hourlyUnits = json['hourlyUnits'] != null
        ? HourlyUnits.fromJson(json['hourlyUnits'])
        : null;
    date = json['date'];
    projectPositionId = json['projectPositionId'];
    projectId = json['projectId'];
    projectName = json['projectName'];
    time = json['time'];
    temperature = json['temperature'];
    relativeHumidity = json['relativeHumidity'];
    rain = json['rain'];
    showers = json['showers'];
    pressure = json['pressure'];
    surfacePressure = json['surfacePressure'];
    cloudCover = json['cloudCover'];
    windSpeed = json['windSpeed'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (hourlyUnits != null) {
      map['hourlyUnits'] = hourlyUnits!.toJson();
    }
    map['projectPositionId'] = projectPositionId;
    map['date'] = date;
    map['projectId'] = projectId;
    map['projectName'] = projectName;
    map['time'] = time;
    map['temperature'] = temperature;
    map['relativeHumidity'] = relativeHumidity;
    map['rain'] = rain;
    map['showers'] = showers;
    map['pressure'] = pressure;
    map['surfacePressure'] = surfacePressure;
    map['cloudCover'] = cloudCover;
    map['windSpeed'] = windSpeed;
    return map;
  }
}
