import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:uuid/uuid.dart';
import '../../api/prefs_og.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../data/org_message.dart';
import '../../functions.dart';

class MonitorMessage extends StatefulWidget {
  final String projectId;
  final String userId;

  final CacheManager cacheManager;
  final DataApiDog dataApiDog;

  const MonitorMessage({
    super.key,
    required this.projectId,
    required this.userId,
    required this.cacheManager,
    required this.dataApiDog,
  });

  @override
  MonitorMessageState createState() => MonitorMessageState();
}

class MonitorMessageState extends State<MonitorMessage> {
  String frequency = monitorTwiceADay;
  bool isBusy = false;

  Project? project;
  User? user;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    user = await widget.cacheManager.getUserById(widget.userId);
    project = await widget.cacheManager.getProjectById(projectId: widget.projectId);
    setState(() {});
  }

  void _onRadioButtonSelected(String selected) {
    pp('MessageMobile :  🥦 🥦 🥦 _onRadioButtonSelected: 🍊 $selected 🍊');
    setState(() {
      frequency = selected;
    });
  }

  void _sendMessage() async {
    // if (frequency == null) {
    //   // AppSnackbar.showErrorSnackbar(
    //   //     scaffoldKey: widget.key, message: 'Please select frequency');
    //   return;
    // }

    setState(() {
      isBusy = true;
    });
    var sender = await prefsOGx.getUser();
    if (sender != null && sender.userId != user!.userId) {
      var msg = OrgMessage(
          name: user!.name,
          adminId: sender.userId,
          adminName: sender.name,
          projectName: project!.name,
          frequency: frequency,
          message: 'Please collect info',
          userId: user!.userId,
          created: DateTime.now().toUtc().toIso8601String(),
          projectId: project!.projectId,
          organizationId: project!.organizationId,
          orgMessageId: const Uuid().v4());
      try {
        var res = await widget.dataApiDog.sendMessage(msg);
        pp('MessageMobile:  🏓  🏓  🏓 Response from server:  🏓 ${res.toJson()}  🏓');
      } catch (e) {
        // AppSnackbar.showErrorSnackbar(
        //     scaffoldKey: widget.key, message: 'Message Send failed : $e');
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.app_registration,
            color: Theme.of(context).primaryColor,
          ),
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            width: 300.0,
            child: Text(
              project!.name!,
              style: Styles.blackBoldSmall,
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        // RadioButtonGroup(
        //   labelStyle: Styles.blackSmall,
        //   picked: frequency,
        //   labels: const [
        //     MONITOR_ONCE_A_DAY,
        //     MONITOR_TWICE_A_DAY,
        //     // MONITOR_THREE_A_DAY,
        //     MONITOR_ONCE_A_WEEK
        //   ],
        //   onSelected: _onRadioButtonSelected,
        // ),
        const SizedBox(
          height: 4,
        ),
        isBusy
            ? SizedBox(
                height: 24,
                width: 24,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.pink[200],
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _sendMessage,
                child: Text(
                  'Send Message',
                  style: Styles.whiteSmall,
                )),
        const SizedBox(
          height: 12,
        )
      ],
    );
  }
}
