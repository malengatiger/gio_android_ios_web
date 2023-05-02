import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/camera/video_recorder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:page_transition/page_transition.dart';

import '../../../ui/audio/audio_recorder.dart';
import '../../bloc/project_bloc.dart';
import '../../data/position.dart';
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../functions.dart';
import '../camera/photo_handler.dart';
import '../project_location/project_location_handler.dart';

class ProjectMonitorMobile extends StatefulWidget {
  final Project project;

  const ProjectMonitorMobile({super.key, required this.project});

  @override
  ProjectMonitorMobileState createState() => ProjectMonitorMobileState();
}

///Checks whether the device is within monitoring distance for the project
class ProjectMonitorMobileState extends State<ProjectMonitorMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  final _key = GlobalKey<ScaffoldState>();
  var positions = <ProjectPosition>[];
  var polygons = <ProjectPolygon>[];
  late StreamSubscription<String> killSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getProjectData(false);
  }

  void _getProjectData(bool forceRefresh) async {
    setState(() {
      isBusy = true;
    });
    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      positions = await projectBloc.getProjectPositions(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      polygons = await projectBloc.getProjectPolygons(
          projectId: widget.project.projectId!, forceRefresh: forceRefresh);
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data refresh failed: $e')));
    }

    setState(() {
      widget.project.projectPositions = positions;
      isBusy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    killSubscription.cancel();
    super.dispose();
  }

  bool _showPositionChooser = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Text('Starter',
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodySmall,
                fontWeight: FontWeight.normal,
              )),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded,
                  size: 18, color: Theme.of(context).primaryColor),
              onPressed: () {
                _getProjectData(true);
              },
            ),
            IconButton(
              icon: Icon(Icons.directions,
                  size: 24, color: Theme.of(context).primaryColor),
              onPressed: () {
                setState(() {
                  _showPositionChooser = true;
                });
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(220),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(widget.project.name!, style: myTextStyleMedium(context)),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    'The project should be monitored only when the device is within a radius of',
                    style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text('${widget.project.monitorMaxDistanceInMetres}',
                      style: GoogleFonts.secularOne(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(
                    height: 0,
                  ),
                  const Text('metres'),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(),
            ),
            Positioned(
                child: SizedBox(
                    width: 400,
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    height: 280,
                                    child: Column(
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            _startPhotoMonitoring();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Start Photo Monitor',
                                              style:
                                                  myTextStyleMediumPrimaryColor(
                                                      context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            _startVideoMonitoring();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Start Video Monitor',
                                              style:
                                                  myTextStyleMediumPrimaryColor(
                                                      context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            _startAudioMonitoring();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Start Audio Report',
                                              style:
                                                  myTextStyleMediumPrimaryColor(
                                                      context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: myTextStyleSmall(context),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))),
            _showPositionChooser
                ? Positioned(
                    left: 4,
                    top: 4,
                    child: ProjectLocationChooser(
                      onSelected: _onPositionSelected,
                      onClose: _onClose,
                      projectPositions: positions,
                      polygons: polygons,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  // ignore: missing_return
  // Future<ProjectPosition?> _findNearestProjectPosition() async {
  //   var bags = <BagX>[];
  //   var positions =
  //       await cacheManager.getProjectPositions(widget.project.projectId!);
  //   if (positions.isEmpty) {
  //     _navigateToProjectLocation();
  //   } else {
  //     if (positions.length == 1) {
  //       return positions.first;
  //     }
  //     for (var pos in positions) {
  //       var distance = await locationBlocOG.getDistanceFromCurrentPosition(
  //           latitude: pos.position!.coordinates[1],
  //           longitude: pos.position!.coordinates[0]);
  //       bags.add(BagX(distance, pos));
  //     }
  //     bags.sort((a, b) => a.distance.compareTo(b.distance));
  //   }
  //   return bags.first.position;
  // }

  // bool isWithinDistance = false;
  ProjectPosition? nearestProjectPosition;
  static const mm = '🍏 🍏 🍏 ProjectMonitorMobile: 🍏 : ';

  void _startPhotoMonitoring() async {
    pp('🍏 🍏 Start Photo Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: PhotoHandler(
              project: widget.project,
              projectPosition: null,
            )));
  }

  void _startVideoMonitoring() async {
    pp('🍏 🍏 Start Video Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: VideoRecorder(
              project: widget.project,
              projectPosition: null, onClose: (){
                Navigator.of(context).pop();
            },
            )));
  }

  void _startAudioMonitoring() async {
    pp('🍏 🍏 Start Audio Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: AudioRecorder(onCloseRequested: (){
              pp('On stop requested');
              Navigator.of(context).pop();
            }, project: widget.project),
        ));
  }

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'You are too far from the project for monitoring to work properly')));
    setState(() {
      isBusy = false;
    });
  }

  void _navigateToDirections(
      {required double latitude, required double longitude}) async {
    pp('$mm 🍎 🍎 🍎 start Google Maps Directions .....');

    final availableMaps = await MapLauncher.installedMaps;
    pp('$mm 🍎 🍎 🍎 availableMaps: $availableMaps'); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    var coordinates = Coords(latitude, longitude);
    await availableMaps.first.showDirections(destination: coordinates);
  }

  void _navigateToProjectLocation() async {
    pp('🏖 🍎 🍎 🍎 ... _navigateToProjectLocation ....');
    var projectPosition = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectLocationHandler(widget.project)));
  }

  _onPositionSelected(Position p1) {
    setState(() {
      _showPositionChooser = false;
    });

    _navigateToDirections(
        latitude: p1.coordinates[1], longitude: p1.coordinates[0]);
  }

  _onClose() {
    setState(() {
      _showPositionChooser = false;
    });
  }
}

class BagX {
  double distance;
  ProjectPosition position;

  BagX(this.distance, this.position);
}

/// choose projectPosition or one of the polygon points
///
///
class ProjectLocationChooser extends StatelessWidget {
  const ProjectLocationChooser(
      {Key? key,
      this.projectPositions,
      this.polygons,
      required this.onSelected,
      required this.onClose})
      : super(key: key);

  final List<ProjectPosition>? projectPositions;
  final List<ProjectPolygon>? polygons;
  final Function(Position) onSelected;
  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    var positions = <Position>[];
    if (projectPositions != null) {
      for (var p in projectPositions!) {
        positions.add(p.position!);
      }
    }
    if (polygons != null) {
      for (var p in polygons!) {
        positions.addAll(p.positions);
      }
    }

    return Container(
      color: Theme.of(context).primaryColorDark,
      width: 320,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      onClose();
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            SizedBox(
              child: Text(
                'Tap to select location for directions',
                style: myTextStyleSmall(context),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (context, index) {
                    // var pos = positions.elementAt(index);

                    return GestureDetector(
                      onTap: () {
                        onSelected(positions.elementAt(index));
                      },
                      child: Card(
                        shape: getRoundedBorder(radius: 16),
                        elevation: 8,
                        child: ListTile(
                          dense: true,
                          title: Row(
                            children: [
                              Text(
                                'Project Location',
                                style: myTextStyleMedium(context),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '# ${index + 1}',
                                style: myNumberStyleSmall(context),
                              ),
                            ],
                          ),
                          leading: Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
