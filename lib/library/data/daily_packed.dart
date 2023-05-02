import 'package:hive/hive.dart';
import '../data/position.dart';

part 'daily_packed.g.dart';
/*
    String time;
    int weatherCode;
    double minTemperature, maxTemperature;
    double apparentMinTemp, apparentMaxTemp;
    String sunrise, sunset;
    double precipitationSum, rainSum, showersSum;
    double precipitationHours, windSpeedMax;
    Double windDirectionDominant;
    double shortwaveRadiation, evapoTranspiration;

 */

@HiveType(typeId: 40)
class DailyPacked extends HiveObject {
  @HiveField(0)
  int? weatherCode;
  @HiveField(1)
  double? minTemperature;
  @HiveField(2)
  double? maxTemperature;
  @HiveField(3)
  String? time;
  @HiveField(4)
  double? apparentMinTemp;
  @HiveField(5)
  double? apparentMaxTemp;
  @HiveField(6)
  String? sunrise;
  @HiveField(7)
  String? sunset;
  @HiveField(8)
  double? precipitationSum;

  @HiveField(9)
  double? rainSum;
  @HiveField(10)
  double? showersSum;
  @HiveField(11)
  double? precipitationHours;
  @HiveField(12)
  double? windSpeedMax;
  @HiveField(13)
  double? windDirectionDominant;

  @HiveField(14)
  double? shortwaveRadiation;
  @HiveField(15)
  double? evapoTranspiration;

  DailyPacked({
    required this.weatherCode,
    required this.maxTemperature,
    required this.time,
    required this.sunrise,
    required this.sunset,
    required this.precipitationSum,
    required this.minTemperature,
    required this.apparentMinTemp,
    required this.apparentMaxTemp,
    required this.evapoTranspiration,
    required this.precipitationHours,
    required this.rainSum,
    required this.shortwaveRadiation,
    required this.showersSum,
    required this.windDirectionDominant,
    required this.windSpeedMax,
  });

  DailyPacked.fromJson(Map data) {
    evapoTranspiration = data['evapoTranspiration'];
    precipitationHours = data['precipitationHours'];
    rainSum = data['rainSum'];
    shortwaveRadiation = data['shortwaveRadiation'];
    showersSum = data['showersSum'];
    windDirectionDominant = data['windDirectionDominant'];
    windSpeedMax = data['windSpeedMax'];

    apparentMaxTemp = data['apparentMaxTemp'];
    weatherCode = data['weatherCode'];
    minTemperature = data['minTemperature'];
    maxTemperature = data['maxTemperature'];
    time = data['time'];
    sunrise = data['sunrise'];
    apparentMinTemp = data['apparentMinTemp'];
    sunset = data['sunset'];
    precipitationSum = data['precipitationSum'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'weatherCode': weatherCode,
      'evapoTranspiration': evapoTranspiration,
      'precipitationHours': precipitationHours,
      'rainSum': rainSum,
      'shortwaveRadiation': shortwaveRadiation,
      'showersSum': showersSum,
      'windDirectionDominant': windDirectionDominant,
      'windSpeedMax': windSpeedMax,
      'apparentMaxTemp': apparentMaxTemp,
      'maxTemperature': maxTemperature,
      'time': time,
      'sunrise': sunrise,
      'apparentMinTemp': apparentMinTemp,
      'sunset': sunset,
      'precipitationSum': precipitationSum,
      'minTemperature': minTemperature,
    };
    return map;
  }
}
