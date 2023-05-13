import 'dart:collection';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';


import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/organization_bloc.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../data/weather/daily_forecast.dart';
import '../../emojis.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class DailyForecastPage extends StatefulWidget {
  const DailyForecastPage({Key? key}) : super(key: key);

  @override
  DailyForecastPageState createState() => DailyForecastPageState();
}

class DailyForecastPageState extends State<DailyForecastPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm =
      '${E.nice}${E.nice}${E.nice}${E.nice}${E.nice} DailyForecastPage: ';

  DailyForecast? dailyForecast;
  var forecastBags = <ForecastBag>[];
  var positions = <ProjectPosition>[];
  bool busy = false;
  User? user;

  var currentForecasts = <DailyForecast>[];

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getDailyForecasts();
  }

  void _getDailyForecasts() async {
    setState(() {
      busy = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () async {
      try {
        pp('$mm  get project positions and get forecast for each ....');
        user = await prefsOGx.getUser();
        var mapX = await getStartEndDates();
        final startDate = mapX['startDate'];
        final endDate = mapX['endDate'];
        positions = await organizationBloc.getProjectPositions(
            organizationId: user!.organizationId!, forceRefresh: false, startDate: startDate!, endDate: endDate!);
        //todo filter positions - use distance to identify what positions qualfy ..
        //for now - 1 position per project
        var map = HashMap<String, ProjectPosition>();
        for (var pos in positions) {
          if (map.containsKey(pos.projectId)) {
            //ignore
          } else {
            map[pos.projectId!] = pos;
          }
        }
        //todo - map contains the first position of every project
        //for now, take everyone but later filter with distance from here
        var mPositions = map.values.toList();
        pp('\n$mm getting daily forecast for project positions: ${mPositions.length} 🍎🍎🍎🍎');

        for (var pos in mPositions) {
          String tz = latLngToTimezoneString(
              pos.position!.coordinates[1], pos.position!.coordinates[0]);
          final forecasts = await dataApiDog.getDailyForecast(
              latitude: pos.position!.coordinates[1],
              longitude: pos.position!.coordinates[0],
              timeZone: tz,
              projectId: pos.projectId!,
              projectName: pos.projectName!,
              projectPositionId: pos.projectPositionId!);

          pp('$mm daily forecast received: ${pos.projectName} 🍎 ${forecasts.length} forecasts🍎🍎🍎🍎');
          //
          forecastBags
              .add(ForecastBag(projectPosition: pos, forecasts: forecasts));
        }
        pp('\n\n$mm 🔵🔵🔵 All Daily Forecasts per ProjectPosition: 🔵🔵🔵 ${forecastBags.length}');

        await _setCurrentForecasts();
      } catch (e) {
        pp(e);
        if (mounted) {
          showToast(message: '$e', context: context);
        }
      }
     if (mounted) {
       setState(() {
         busy = false;
       });
     }
    });
  }

  Future<void> _setCurrentForecasts() async {
    for (var bag in forecastBags) {
      currentForecasts.add(bag.forecasts.first);
    }
    if (currentForecasts.length == 1) {
      //todo 1 project position - so show all 7 days
      currentForecasts = forecastBags.first.forecasts;
    } else {
      var distinctProjectMap = HashMap<String, String>();
      for (var bag in forecastBags) {
        if (distinctProjectMap.containsKey(bag.projectPosition.projectId!)) {
          //ignore
        } else {
          distinctProjectMap[bag.projectPosition.projectId!] = "Don't matte";
        }
      }

      if (distinctProjectMap.length == 1) {
        //todo this project could have just 1 position OR has multiple project positions
        var id = distinctProjectMap.keys.toList().first;
        var positions = await cacheManager.getProjectPositions(id);
        if (positions.length == 1) {
          currentForecasts = forecastBags.first.forecasts;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Daily Weather Forecast'),
      ),
      body: Stack(
        children: [
          busy
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Card(
                      elevation: 8,
                      shape: getRoundedBorder(radius: 16),
                      child: SizedBox(
                        height: 160,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 48,
                            ),
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 4, backgroundColor: Colors.pink),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Loading daily forecasts ... '),
                                SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : OneDayProjectPositionForecastsPage(forecasts: currentForecasts),
        ],
      ),
    ));
  }
}

class ForecastBag {
  late ProjectPosition projectPosition;
  late List<DailyForecast> forecasts;

  ForecastBag({required this.projectPosition, required this.forecasts});
}

class DayForecastCard extends StatefulWidget {
  const DayForecastCard({Key? key, required this.forecast}) : super(key: key);

  final DailyForecast forecast;
  @override
  State<DayForecastCard> createState() => _DayForecastCardState();
}

class _DayForecastCardState extends State<DayForecastCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 460,
          child: Card(
            elevation: 4,
            shape: getRoundedBorder(radius: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    getFormattedDateLong(widget.forecast.date!, context),
                    style: myTextStyleSmall(context),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    widget.forecast.projectName!,
                    style: myTextStyleMedium(context),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        '${widget.forecast.apparentMaxTemp}',
                        style: myNumberStyleLargest(context),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        ' \u2103 ',
                        style: myTextStyleMedium(context),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      const Image(
                        width: 32,
                        height: 32,
                        image: AssetImage(
                          'assets/weather/cloudy.png',
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SunriseSunset(
                      sunrise: getFormattedDateHour(widget.forecast.sunrise!),
                      sunset: getFormattedDateHour(widget.forecast.sunset!)),
                  RainAndShowers(
                      rain: widget.forecast.rainSum!,
                      showers: widget.forecast.showersSum!),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      const Text('Minimum Temperature: '),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${widget.forecast.minTemperature}',
                        style: myNumberStyleLargerPrimaryColor(context),
                      ),
                      Text(
                        ' \u2103 ',
                        style: myTextStyleMedium(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class RainAndShowers extends StatelessWidget {
  const RainAndShowers({Key? key, required this.rain, required this.showers})
      : super(key: key);
  final double rain, showers;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 40.0, right: 40.0, top: 12, bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Rain'),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '${rain * 100}',
                  style: myNumberStyleLargerPrimaryColor(context),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text('%'),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text('Showers'),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '$showers',
                  style: myNumberStyleLargerPrimaryColor(context),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text('%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SunriseSunset extends StatelessWidget {
  const SunriseSunset({Key? key, required this.sunrise, required this.sunset})
      : super(key: key);
  final String sunrise, sunset;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sunrise',
                style: myTextStyleSmall(context),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                sunrise,
                style: myNumberStyleLarge(context),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sunset', style: myTextStyleSmall(context)),
              const SizedBox(
                width: 8,
              ),
              Text(sunset, style: myNumberStyleLarge(context)),
            ],
          ),
        ],
      ),
    );
  }
}

///one day forecast for each project position OR if org has just one project
class OneDayProjectPositionForecastsPage extends StatefulWidget {
  const OneDayProjectPositionForecastsPage({Key? key, required this.forecasts})
      : super(key: key);
  final List<DailyForecast> forecasts;
  @override
  State<OneDayProjectPositionForecastsPage> createState() =>
      _OneDayProjectPositionForecastsPageState();
}

class _OneDayProjectPositionForecastsPageState
    extends State<OneDayProjectPositionForecastsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0, duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 48,
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text(
                'This is the weather forecast at all your project locations. '
                'Swipe right to see the rest of the show! ',
                style: myTextStyleSmall(context),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                    itemCount: widget.forecasts.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      var fc = widget.forecasts.elementAt(index);
                      return AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget? child) {
                            return FadeScaleTransition(
                              animation: _animationController,
                              child: child,
                            );
                          },
                          child: DayForecastCard(forecast: fc));
                    }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
