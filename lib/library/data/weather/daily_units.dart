import 'package:hive/hive.dart';
part 'daily_units.g.dart';

@HiveType(typeId: 51)
class DailyUnits {
  @HiveField(0)
  String? time;
  @HiveField(1)
  String? weathercode;
  @HiveField(2)
  String? temperature2mMax;
  @HiveField(3)
  String? temperature2mMin;
  @HiveField(4)
  String? apparentTemperatureMax;
  @HiveField(5)
  String? apparentTemperatureMin;
  @HiveField(6)
  String? sunrise;
  @HiveField(7)
  String? sunset;
  @HiveField(8)
  String? precipitationSum;
  @HiveField(9)
  String? rainSum;
  @HiveField(10)
  String? showersSum;
  @HiveField(11)
  String? snowfallSum;
  @HiveField(12)
  String? precipitationHours;
  @HiveField(13)
  String? windspeed10mMax;
  @HiveField(14)
  String? windgusts10mMax;
  @HiveField(15)
  String? winddirection10mDominant;
  @HiveField(16)
  String? shortwaveRadiationSum;
  @HiveField(17)
  String? et0FaoEvapotranspiration;
  DailyUnits({
    this.time,
    this.weathercode,
    this.temperature2mMax,
    this.temperature2mMin,
    this.apparentTemperatureMax,
    this.apparentTemperatureMin,
    this.sunrise,
    this.sunset,
    this.precipitationSum,
    this.rainSum,
    this.showersSum,
    this.snowfallSum,
    this.precipitationHours,
    this.windspeed10mMax,
    this.windgusts10mMax,
    this.winddirection10mDominant,
    this.shortwaveRadiationSum,
    this.et0FaoEvapotranspiration,
  });

  DailyUnits.fromJson(Map json) {
    time = json['time'];
    weathercode = json['weathercode'];
    temperature2mMax = json['temperature_2m_max'];
    temperature2mMin = json['temperature_2m_min'];
    apparentTemperatureMax = json['apparent_temperature_max'];
    apparentTemperatureMin = json['apparent_temperature_min'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    precipitationSum = json['precipitation_sum'];
    rainSum = json['rain_sum'];
    showersSum = json['showers_sum'];
    snowfallSum = json['snowfall_sum'];
    precipitationHours = json['precipitation_hours'];
    windspeed10mMax = json['windspeed_10m_max'];
    windgusts10mMax = json['windgusts_10m_max'];
    winddirection10mDominant = json['winddirection_10m_dominant'];
    shortwaveRadiationSum = json['shortwave_radiation_sum'];
    et0FaoEvapotranspiration = json['et0_fao_evapotranspiration'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['weathercode'] = weathercode;
    map['temperature_2m_max'] = temperature2mMax;
    map['temperature_2m_min'] = temperature2mMin;
    map['apparent_temperature_max'] = apparentTemperatureMax;
    map['apparent_temperature_min'] = apparentTemperatureMin;
    map['sunrise'] = sunrise;
    map['sunset'] = sunset;
    map['precipitation_sum'] = precipitationSum;
    map['rain_sum'] = rainSum;
    map['showers_sum'] = showersSum;
    map['snowfall_sum'] = snowfallSum;
    map['precipitation_hours'] = precipitationHours;
    map['windspeed_10m_max'] = windspeed10mMax;
    map['windgusts_10m_max'] = windgusts10mMax;
    map['winddirection_10m_dominant'] = winddirection10mDominant;
    map['shortwave_radiation_sum'] = shortwaveRadiationSum;
    map['et0_fao_evapotranspiration'] = et0FaoEvapotranspiration;
    return map;
  }
}
