import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_monitor/initializer.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/data/data_bag.dart';
import 'package:riverpod/riverpod.dart';

import '../library/functions.dart';

class TestRiverPod extends ConsumerStatefulWidget {
  const TestRiverPod({Key? key}) : super(key: key);

  @override
  TestRiverPodState createState() => TestRiverPodState();
}

class TestRiverPodState extends ConsumerState<TestRiverPod> {
 final mm = '🔶🔶🔶🔶🔶🔶 TestRiverPod 🔶🔶🔶🔶🔶🔶';
  DataBag? bag;

  @override
  void initState() {
    super.initState();
    _getData();
  }
  void _getData() async {
    //final sett = await prefsOGx.getSettings();
    pp('$mm _getData: start watching the provider ...');
    await initializer.setupGio();
    pp('$mm _getData: initializer complete ...');
    final mBak  = ref.watch(getOrganizationDataProvider);
    pp('$mm _getData: bag delivered ?? ... $mBak');
    mBak.when(data: (data){
      pp('$mm ............. Projects ... ${data!.projects!.length}');
      pp('$mm ............. activities: ... ${data!.activityModels!.length}');
      pp('$mm .............users ... ${data!.users!.length}');


    }, error: (error, _){
      pp('$mm $error');
    }, loading: (){
      pp('$mm ............. Loading data .......');
    });

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: (){
        _getData();
      }, child: Text('Get Data?', style: myNumberStyleBig(context),)),
    );
  }
}
