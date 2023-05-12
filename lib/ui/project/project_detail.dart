import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';

import 'package:page_transition/page_transition.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/data/community.dart';
import '../../library/data/project.dart';
import '../../library/data/user.dart';

import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import 'project_editor.dart';

/// shows the details for projects
class ProjectDetail extends StatefulWidget {
  final Project project;

  const ProjectDetail({super.key, required this.project});

  @override
  ProjectDetailState createState() => ProjectDetailState();
}

class ProjectDetailState extends State<ProjectDetail> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late Project project;

  @override
  void initState() {
    super.initState();
    prettyPrint(widget.project.toJson(), '♻️ ♻️ ♻️ Project  ♻️♻️');
    project = widget.project;
    _getData();
  }

  _getData() async {
    _buildNav();
    user = await prefsOGx.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Project Details'),
        elevation: 8.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  '${project.name}',
                  style: Styles.blackBoldMedium,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  '${project.description}',
                  style: Styles.whiteSmall,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.brown[50],
      body: Stack(
        children: <Widget>[
          isBusy
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 28.0, left: 8),
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(
                        height: 8,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: Card(
                          elevation: 4,
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  getFormattedNumber(0, context),
                                  style: Styles.blackBoldLarge,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Questionnaires'),
                                const SizedBox(
                                  height: 8,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                            width: 140,
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.scale,
                                //         alignment: Alignment.topLeft,
                                //         duration: const Duration(seconds: 1),
                                //         child: PhotoGallery(
                                //           project: project,
                                //         )));
                              },
                              child: Card(
                                elevation: 4,
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        getFormattedNumber(project.photos!.length, context),
                                        style: Styles.purpleBoldLarge,
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      const Text('Photos'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: 140,
                            child: Card(
                              elevation: 4,
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      getFormattedNumber(project.videos!.length, context),
                                      style: Styles.tealBoldLarge,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text('Videos'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: project.communities!.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                            width: 140,
                            child: Card(
                              elevation: 4,
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      getFormattedNumber(project.ratings!.length, context),
                                      style: Styles.pinkBoldLarge,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text('Ratings'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          project.communities!.isEmpty
                              ? Container()
                              : SizedBox(
                                  height: 100,
                                  width: 140,
                                  child: Card(
                                    elevation: 4,
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            getFormattedNumber(project.communities!.length, context),
                                            style: Styles.blueBoldLarge,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          const Text('Settlements'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
          Positioned(
            left: 20,
            top: 20,
            child: Image.asset(
              'assets/hda.png',
              width: 64,
              height: 64,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        onTap: _navTapped,
      ),
    );
  }

  User? user;
  bool isBusy = false;
  List<BottomNavigationBarItem> navItems = [];
  _buildNav() {
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.create),
      label: 'Edit',
    ));
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.brightness_auto),
      label: 'Settlements',
    ));
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ));
  }

  void _navTapped(int value) {
    //todo - check usertype
    switch (value) {
      case 0:
        pp('Questionnaire Nav  tapped');
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(seconds: 1),
                child: const ProjectEditor()));

        break;
      case 1:
        pp('Project Nav  tapped');
        showToast(message: 'Under Construction', context: context);

        break;
      case 2:
        pp('Map Nav  tapped');
        showToast(message: 'Under Construction', context: context);
        break;
    }
  }

  void _onRefresh() async {
    try {
      debugPrint('✳️ ✳️ ✳️ ......  refresh project');
     // project = await dataApiDog.getproje(project.projectId!);
      debugPrint('✳️ ✳️ ✳️ ......  refresh project done, set state ...');
      setState(() {});
    } catch (e) {
      showToast(message: '$e', context: context);
    }
  }
}

class Basics extends StatelessWidget {
  final Community settlement;
  const Basics({
    Key? key,
    required this.settlement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 8,
          ),
          Text('${settlement.email}'),
          const SizedBox(
            height: 8,
          ),
          Text('${settlement.countryName}'),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Population'),
              const SizedBox(
                width: 12,
              ),
              Text(
                getFormattedNumber(settlement.population!, context),
                style: Styles.blackBoldMedium,
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
