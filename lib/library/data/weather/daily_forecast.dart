import 'package:hive/hive.dart';

import 'daily_units.dart';
part 'daily_forecast.g.dart';

@HiveType(typeId: 50)
class DailyForecast {
  @HiveField(0)
  DailyUnits? dailyUnits;
  @HiveField(1)
  String? time;
  @HiveField(2)
  int? weatherCode;
  @HiveField(3)
  double? minTemperature;
  @HiveField(4)
  double? maxTemperature;
  @HiveField(5)
  double? apparentMinTemp;
  @HiveField(6)
  double? apparentMaxTemp;
  @HiveField(7)
  String? sunrise;
  @HiveField(8)
  String? sunset;
  @HiveField(9)
  double? precipitationSum;
  @HiveField(10)
  double? rainSum;
  @HiveField(11)
  double? showersSum;
  @HiveField(12)
  double? precipitationHours;
  @HiveField(13)
  double? windSpeedMax;
  @HiveField(14)
  double? windDirectionDominant;
  @HiveField(15)
  double? shortwaveRadiation;
  @HiveField(16)
  double? evapoTranspiration;
  @HiveField(17)
  String? projectPositionId;
  @HiveField(18)
  String? date;
  @HiveField(19)
  String? projectId;
  @HiveField(20)
  String? projectName;

  DailyForecast({
    this.dailyUnits,
    this.time,
    this.weatherCode,
    this.minTemperature,
    this.maxTemperature,
    this.apparentMinTemp,
    this.apparentMaxTemp,
    this.sunrise,
    this.sunset,
    this.precipitationSum,
    this.rainSum,
    this.showersSum,
    this.precipitationHours,
    this.windSpeedMax,
    this.windDirectionDominant,
    this.shortwaveRadiation,
    this.evapoTranspiration,
    this.projectPositionId, this.date,
    this.projectId, this.projectName,
  });

  DailyForecast.fromJson(Map json) {

    time = json['time'];
    date = json['date'];
    projectPositionId = json['projectPositionId'];
    projectId = json['projectId'];
    projectName = json['projectName'];
    weatherCode = json['weatherCode'];
    minTemperature = json['minTemperature'];
    maxTemperature = json['maxTemperature'];
    apparentMinTemp = json['apparentMinTemp'];
    apparentMaxTemp = json['apparentMaxTemp'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    precipitationSum = json['precipitationSum'];
    rainSum = json['rainSum'];
    showersSum = json['showersSum'];
    precipitationHours = json['precipitationHours'];
    windSpeedMax = json['windSpeedMax'];
    windDirectionDominant = json['windDirectionDominant'];
    shortwaveRadiation = json['shortwaveRadiation'];
    evapoTranspiration = json['evapoTranspiration'];
    if (json['dailyUnits'] != null) {
      dailyUnits = DailyUnits.fromJson(json['dailyUnits']);
    }

  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dailyUnits != null) {
      map['dailyUnits'] = dailyUnits!.toJson();
    }
    map['time'] = time;
    map['date'] = date;
    map['projectId'] = projectId;
    map['projectName'] = projectName;
    map['projectPositionId'] = projectPositionId;

    map['weatherCode'] = weatherCode;
    map['minTemperature'] = minTemperature;
    map['maxTemperature'] = maxTemperature;
    map['apparentMinTemp'] = apparentMinTemp;
    map['apparentMaxTemp'] = apparentMaxTemp;
    map['sunrise'] = sunrise;
    map['sunset'] = sunset;
    map['precipitationSum'] = precipitationSum;
    map['rainSum'] = rainSum;
    map['showersSum'] = showersSum;
    map['precipitationHours'] = precipitationHours;
    map['windSpeedMax'] = windSpeedMax;
    map['windDirectionDominant'] = windDirectionDominant;
    map['shortwaveRadiation'] = shortwaveRadiation;
    map['evapoTranspiration'] = evapoTranspiration;
    return map;
  }
}
