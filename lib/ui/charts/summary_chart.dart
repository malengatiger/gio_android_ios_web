import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/project_summary.dart';
import 'package:geo_monitor/ui/charts/bar_chart.dart';

import '../../library/bloc/organization_bloc.dart';
import '../../library/data/project.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import 'date_card.dart';

class ProjectSummaryChart extends StatefulWidget {
  const ProjectSummaryChart({Key? key, this.project}) : super(key: key);

  final Project? project;

  @override
  ProjectSummaryChartState createState() => ProjectSummaryChartState();
}

class ProjectSummaryChartState extends State<ProjectSummaryChart>
    with SingleTickerProviderStateMixin {
  final mm = '😎😎😎😎😎😎 ProjectSummaryChart: ';
  late AnimationController _controller;
  var summaries = <ProjectSummary>[];
  User? user;
  String? startDate, endDate;

  DateTimeRange? dateTimeRange;
  bool _showChart = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getDateRange();
  }

  Future _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
      _showChart = false;
    });

    if (dateTimeRange == null) {
      return;
    }

    pp('$mm ... getting summary data ... forceRefresh: $forceRefresh');
    try {
      user = await prefsOGx.getUser();
      pp('$mm ... get summaries 🔵🔵 startDate: ${dateTimeRange!.start} '
          ' endDate: ${dateTimeRange!.end}');
      if (widget.project != null) {
        pp('$mm ... widget.project != null, should get project data');
        await _getProjectData(
            forceRefresh,
            dateTimeRange!.start.toIso8601String(),
            dateTimeRange!.end.toIso8601String());
      } else {
        pp('$mm ... widget.project == null, should get organization data');
        await _getOrganizationData(
            forceRefresh,
            dateTimeRange!.start.toIso8601String(),
            dateTimeRange!.end.toIso8601String());
      }
      _showChart = true;
      //todo - remove after test
      for (var value in summaries) {
        pp('$mm summary: ${value.toJson()}');
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _getOrganizationData(
      bool forceRefresh, String startDate, String endDate) async {
    summaries = await organizationBloc.getOrganizationDailySummaries(
        organizationId: user!.organizationId!,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh);
    _sortAscending();
  }

  Future _getProjectData(
      bool forceRefresh, String startDate, String endDate) async {
    summaries = await organizationBloc.getProjectDailySummaries(
        projectId: user!.organizationId!,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh);
    _sortAscending();
  }

  bool sortedByDateAscending = false;

  void _sortDescending() {
    summaries.sort((a, b) => b.date!.compareTo(a.date!));
    sortedByDateAscending = false;
  }

  void _sortAscending() {
    summaries.sort((a, b) => a.date!.compareTo(b.date!));
    sortedByDateAscending = true;
  }

  void _getDateRange() async {
    int year = DateTime.now().year;
    int last = year - 1;

    Future.delayed(const Duration(milliseconds: 200), () async {
      dateTimeRange = await showDateRangePicker(
          context: context,
          currentDate: DateTime.now(),
          firstDate: DateTime(year - 1),
          lastDate: DateTime.now());

      pp('$mm dateTimeRange selected: $dateTimeRange');
      setState(() {});
      _getData(false);
    });
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
        title: const Text('Charts'),
        actions: [
          IconButton(
              onPressed: () {
                _getData(true);
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: getRoundedBorder(radius: 16),
              child: Column(
                children: [
                  dateTimeRange == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 24),
                          child: DateCard(
                              dateTimeRange: dateTimeRange!,
                              onRefreshRequested: _getDateRange),
                        ),
                  const SizedBox(
                    height: 48,
                  ),
                  dateTimeRange == null
                      ? const SizedBox()
                      : Expanded(
                          child: Center(
                            child: busy
                                ? Card(
                                    elevation: 8,
                                    shape: getRoundedBorder(radius: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: 300,
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 48,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4,
                                                backgroundColor: Colors.pink,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 48,
                                            ),
                                            Text(
                                              'Loading chart data ....\n\nMay take a minute or two',
                                              style: myTextStyleSmall(context),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      _getData(true);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Build Charts for the period',
                                        style: myTextStyleMediumBold(context),
                                      ),
                                    )),
                          ),
                        ),
                ],
              ),
            ),
          ),
          _showChart
              ? Positioned(
                  left: 48,
                  right: 48,
                  top: 200,
                  child: Card(
                    shape: getRoundedBorder(radius: 16),
                    child: SizedBox(
                      width: 600,
                      height: 400,
                      child: TheBarChart(
                        summaries: summaries,
                      ),
                      // child: TheLineChart(summaries: summaries, height: 300, width: 600,),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    ));
  }
}
