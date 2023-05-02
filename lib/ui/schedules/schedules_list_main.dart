
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'schedules_list_desktop.dart';
import 'schedules_list_mobile.dart';
import 'schedules_list_tablet.dart';

class SchedulesListMain extends StatelessWidget {
  const SchedulesListMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: const SchedulesListMobile(),
      tablet: const SchedulesListTablet(),
      desktop: const SchedulesListDesktop(),
    );
  }
}
