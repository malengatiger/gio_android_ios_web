import 'package:hive/hive.dart';
part 'hourly_units.g.dart';

@HiveType(typeId: 53)
class HourlyUnits {
  @HiveField(0)
  String? time;
  @HiveField(1)
  String? temperature2m;
  @HiveField(2)
  String? relativehumidity2m;
  @HiveField(3)
  String? rain;
  @HiveField(4)
  String? showers;
  @HiveField(5)
  String? pressureMsl;
  @HiveField(6)
  String? surfacePressure;
  @HiveField(7)
  String? cloudcover;
  @HiveField(8)
  String? cloudcoverLow;
  @HiveField(9)
  String? cloudcoverMid;
  @HiveField(10)
  String? cloudcoverHigh;
  @HiveField(11)
  String? windspeed10m;
  @HiveField(12)
  String? windspeed80m;
  @HiveField(13)
  String? windspeed120m;
  @HiveField(14)
  String? windspeed180m;
  @HiveField(15)
  String? winddirection80m;
  @HiveField(16)
  String? temperature80m;
  @HiveField(17)
  String? temperature120m;
  @HiveField(18)
  String? temperature180m;
  HourlyUnits({
    this.time,
    this.temperature2m,
    this.relativehumidity2m,
    this.rain,
    this.showers,
    this.pressureMsl,
    this.surfacePressure,
    this.cloudcover,
    this.cloudcoverLow,
    this.cloudcoverMid,
    this.cloudcoverHigh,
    this.windspeed10m,
    this.windspeed80m,
    this.windspeed120m,
    this.windspeed180m,
    this.winddirection80m,
    this.temperature80m,
    this.temperature120m,
    this.temperature180m,
  });

  HourlyUnits.fromJson(dynamic json) {
    time = json['time'];
    temperature2m = json['temperature_2m'];
    relativehumidity2m = json['relativehumidity_2m'];
    rain = json['rain'];
    showers = json['showers'];
    pressureMsl = json['pressure_msl'];
    surfacePressure = json['surface_pressure'];
    cloudcover = json['cloudcover'];
    cloudcoverLow = json['cloudcover_low'];
    cloudcoverMid = json['cloudcover_mid'];
    cloudcoverHigh = json['cloudcover_high'];
    windspeed10m = json['windspeed_10m'];
    windspeed80m = json['windspeed_80m'];
    windspeed120m = json['windspeed_120m'];
    windspeed180m = json['windspeed_180m'];
    winddirection80m = json['winddirection_80m'];
    temperature80m = json['temperature_80m'];
    temperature120m = json['temperature_120m'];
    temperature180m = json['temperature_180m'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['temperature_2m'] = temperature2m;
    map['relativehumidity_2m'] = relativehumidity2m;
    map['rain'] = rain;
    map['showers'] = showers;
    map['pressure_msl'] = pressureMsl;
    map['surface_pressure'] = surfacePressure;
    map['cloudcover'] = cloudcover;
    map['cloudcover_low'] = cloudcoverLow;
    map['cloudcover_mid'] = cloudcoverMid;
    map['cloudcover_high'] = cloudcoverHigh;
    map['windspeed_10m'] = windspeed10m;
    map['windspeed_80m'] = windspeed80m;
    map['windspeed_120m'] = windspeed120m;
    map['windspeed_180m'] = windspeed180m;
    map['winddirection_80m'] = winddirection80m;
    map['temperature_80m'] = temperature80m;
    map['temperature_120m'] = temperature120m;
    map['temperature_180m'] = temperature180m;
    return map;
  }
}
