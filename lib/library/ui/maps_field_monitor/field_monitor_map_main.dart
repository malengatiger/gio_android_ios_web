import 'package:flutter/material.dart';

import 'package:responsive_builder/responsive_builder.dart';
import '../../data/user.dart';
import '../../data/position.dart';
import '../../functions.dart';

import 'field_monitor_map_desktop.dart';
import 'field_monitor_map_mobile.dart';
import 'field_monitor_map_tablet.dart';

class FieldMonitorMapMain extends StatefulWidget {
  final User user;

  const FieldMonitorMapMain(this.user, {super.key});

  @override
  FieldMonitorMapMainState createState() => FieldMonitorMapMainState();
}

class FieldMonitorMapMainState extends State<FieldMonitorMapMain> {
  var isBusy = false;
  final _key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  void _updateUserPosition({required double latitude, required double longitude}) async {
    setState(() {
      isBusy = true;
    });
    try {
      widget.user.position =
          Position(type: 'Point', coordinates: [longitude, latitude]);
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data refresh failed: $e')));
    }
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? SafeArea(
            child: Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Loading Project locations',
                  style: Styles.whiteTiny,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 12,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: FieldMonitorMapMobile(
              widget.user,
            ),
            tablet: FieldMonitorMapTablet(widget.user),
            desktop: FieldMonitorMapDesktop(widget.user),
          );
  }
}
