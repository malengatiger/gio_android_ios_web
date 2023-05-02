import 'package:flutter/material.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/user_bloc.dart';
import '../../library/data/field_monitor_schedule.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';


class SchedulesListTablet extends StatefulWidget {
  const SchedulesListTablet({super.key});

  @override
  SchedulesListTabletState createState() => SchedulesListTabletState();
}

class SchedulesListTabletState extends State<SchedulesListTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  User? _user;
  List<FieldMonitorSchedule> _schedules = [];
  bool busy = false;
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getData(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = await prefsOGx.getUser();
      _schedules = await userBloc.getFieldMonitorSchedules(
          userId: _user!.userId!, forceRefresh: refresh);
    } catch (e) {
      showToast(message: 'Data refresh failed: $e', context: context);

    }

    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: busy
          ? Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Loading FieldMonitor schedules ...',
                  style: Styles.whiteSmall,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.amber,
                  ),
                ),
              ),
            )
          : Scaffold(
              key: _key,
              appBar: AppBar(
                title: const Text('FieldMonitor Schedules'),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: Column(
                      children: [
                        Text(
                          '${_user == null ? '' : _user!.name!},',
                          style: Styles.whiteBoldMedium,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    )),
              ),
              backgroundColor: Colors.brown[100],
              body: ListView.builder(
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    var sched = _schedules.elementAt(index);
                    var subTitle = _getSubTitle(sched);
                    return Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.alarm,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              '${sched.projectName}',
                              style: Styles.blackBoldSmall,
                            ),
                            subtitle: Text(subTitle),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(getFormattedDateLongWithTime(
                              sched.date!, context)),
                        ],
                      ),
                    );
                  }),
            ),
    );
  }

  String _getSubTitle(FieldMonitorSchedule sc) {
    var string = 'time(s) per Day';
    if (sc.perDay! > 0) {
      return '${sc.perDay} $string';
    }
    if (sc.perWeek! > 0) {
      return '${sc.perWeek} time(s) per Week';
    }
    if (sc.perMonth! > 0) {
      return '${sc.perMonth} time(s) per Month';
    }
    return '';
  }
}
