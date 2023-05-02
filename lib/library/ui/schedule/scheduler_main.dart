import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../data/user.dart';
import 'scheduler_desktop.dart';
import 'scheduler_mobile.dart';
import 'scheduler_tablet.dart';

class SchedulerMain extends StatelessWidget {
  final User user;

  const SchedulerMain(this.user, {super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SchedulerMobile(user),
      tablet: SchedulerTablet(user),
      desktop: SchedulerDesktop(user),
    );
  }
}
