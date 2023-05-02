import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:intl/intl.dart';

import '../../library/data/project_summary.dart';
import '../../library/emojis.dart';

class TheLineChart extends StatefulWidget {
  const TheLineChart(
      {Key? key,
      required this.summaries,
      required this.width,
      required this.height})
      : super(key: key);
  final List<ProjectSummary> summaries;
  final double width, height;

  @override
  State<TheLineChart> createState() => TheLineChartState();
}

class TheLineChartState extends State<TheLineChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ori = MediaQuery.of(context).orientation;
    var isPortrait = false;
    if (ori.name == 'portrait') {
      isPortrait = true;
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AspectRatio(
        aspectRatio: isPortrait ? 2 : 4,
        child: LineChart(
          _buildLineChartData(),
          swapAnimationDuration: const Duration(milliseconds: 500), // Optional
          swapAnimationCurve: Curves.linear,
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    var list = <FlSpot>[];
    _prepareData(list);
    var data = LineChartData(
        // backgroundColor: Colors.teal,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: _bottomTitles),
          leftTitles: AxisTitles(sideTitles: _leftTitles),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
            border: const Border(bottom: BorderSide(), left: BorderSide())),
        lineBarsData: [
          LineChartBarData(
              color: Colors.green,
              isCurved: true,
              barWidth: 4,
              // isStepLineChart: true,
              // isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              lineChartStepData: LineChartStepData(
                  stepDirection: LineChartStepData.stepDirectionMiddle),
              shadow: const Shadow(blurRadius: 8.0),
              show: true,
              // aboveBarData: BarAreaData(show: true, color: Colors.orange),
              // curveSmoothness: 2.0,
              spots: list),
        ]);

    pp('${E.blueDot} MoneyLineChart: .... Prepared List of chart FlSpots: ${list.length}');
    return data;
  }

  void _prepareData(List<FlSpot> mFlSpots) {
    //todo - create chart spots
    pp('${E.blueDot}${E.blueDot} MoneyLineChart: _buildLineChartData starting .... '
        '${E.blueDot} _dashboards: ${widget.summaries.length}');

    widget.summaries.sort((a, b) => a.date!.compareTo(b.date!));

    var map = _consolidatePhotoData();
    map.forEach((key, value) {
      mFlSpots.add(FlSpot(key, value));
    });

    pp('🍊🍊🍊 SummaryChart: each represents one day, ');
    for (var spot in mFlSpots) {
      pp('🍐🍐🍐SummaryChart: FlSpot: x: ${spot.x} - y: ${spot.y}');
    }
  }
  HashMap<double, double> _consolidatePhotoData() {
    var map = HashMap<double, double>();
    for (var value in widget.summaries) {
      var key = double.parse('${value.day}');
      if (map.containsKey(key)) {
        var total = map[key]! + double.parse('${value.photos}') + double.parse('${random.nextInt(50)}');
        map[key] = total;
      } else {
        var total = double.parse('${value.photos}') + double.parse('${random.nextInt(50)}');
        map[key] = total;
      }
    }
    pp('${E.heartRed}${E.heartRed} map: $map');
    return map;
  }

  final random = Random(DateTime.now().millisecondsSinceEpoch);
  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String day = '';
          int b = value.toInt();
          switch (b) {
            case 1:
              day = '01';
              break;
            case 2:
              day = '02';
              break;
            case 3:
              day = '03';
              break;
            case 4:
              day = '04';
              break;
            case 5:
              day = '05';
              break;
            case 6:
              day = '06';
              break;
            case 7:
              day = '07';
              break;
            case 8:
              day = '08';
              break;
            case 9:
              day = '09';
              break;
            case 10:
              day = '10';
              break;
            case 11:
              day = '11';
              break;
            case 12:
              day = '12';
              break;
            case 13:
              day = '13';
              break;
            case 14:
              day = '14';
              break;
            case 15:
              day = '15';
              break;
            case 16:
              day = '16';
              break;
            case 17:
              day = '17';
              break;
            case 18:
              day = '18';
              break;
            case 19:
              day = '19';
              break;
            case 20:
              day = '20';
              break;
            case 21:
              day = '21';
              break;
            case 22:
              day = '22';
              break;
            case 23:
              day = '23';
              break;
            case 24:
              day = '24';
              break;
            case 25:
              day = '25';
              break;
            case 26:
              day = '26';
              break;
            case 27:
              day = '27';
              break;
            case 28:
              day = '28';
              break;
            case 29:
              day = '29';
              break;
            case 30:
              day = '30';
              break;
            case 31:
              day = '31';
              break;
            case 0:
              day = '00';
              break;
          }

          return Text(
            day,
            style: myTextStyleSmallBold(context),
          );
        },
      );

  SideTitles get _leftTitles => SideTitles(
        showTitles: true,
        reservedSize: 48.0,
        getTitlesWidget: (value, meta) {
          var incomingValue = value.toInt();
          var fm = NumberFormat.compact();
          return Text(
            fm.format(incomingValue),
            style: myTextStyleTiny(context),
          );
        },
      );
}
