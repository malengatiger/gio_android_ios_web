import 'package:animations/animations.dart';
import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';

import '../../api/prefs_og.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../functions.dart';

class ProjectChooser extends StatefulWidget {
  const ProjectChooser(
      {Key? key,
      required this.onSelected,
      required this.onClose,
      required this.title,
      required this.height,
      required this.width, required this.prefsOGx})
      : super(key: key);
  final Function(Project) onSelected;
  final Function onClose;
  final String title;
  final double height;
  final double width;
  final PrefsOGx prefsOGx;

  @override
  State<ProjectChooser> createState() => ProjectChooserState();
}

class ProjectChooserState extends State<ProjectChooser>
    with SingleTickerProviderStateMixin {
  List<Project> projects = <Project>[];
  bool loading = false;
  late AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 1500),
        reverseDuration: const Duration(milliseconds: 1500),
        vsync: this);
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _getData() async {
    setState(() {
      loading = true;
    });

    projects = await cacheManager.getOrganizationProjects();
    if (projects.isEmpty) {
      var user = await prefsOGx.getUser();
      projects =
          await dataApiDog.getOrganizationProjects(user!.organizationId!);
    }
    projects.sort((a, b) => b.created!.compareTo(a.created!));

    setState(() {
      loading = false;
    });
    _animationController.forward();
  }

  final txtController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: Colors.pink,
              ),
            ),
          )
        : Stack(
            children: [
              SizedBox(
                height: widget.height, width: widget.width,
                // width: 400,
                child: Card(
                  elevation: 4,
                  color: Theme.of(context).primaryColorDark,
                  shape: getRoundedBorder(radius: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Project ${widget.title}',
                              style: myTextStyleMedium(context),
                            ),
                            const SizedBox(
                              width: 60,
                            ),
                            IconButton(
                                onPressed: (() {
                                  widget.onClose();
                                }),
                                icon: const Icon(
                                  Icons.close,
                                  size: 20.0,
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (BuildContext context, Widget? child) {
                              return FadeScaleTransition(
                                animation: _animationController,
                                child: child,
                              );
                            },
                            child: bd.Badge(
                              badgeContent: Text(
                                '${projects.length}',
                                style: myTextStyleSmall(context),
                              ),
                              badgeStyle: bd.BadgeStyle(
                                badgeColor: Theme.of(context).primaryColor,
                                elevation: 8,
                                padding: const EdgeInsets.all(8),
                              ),
                              position:
                                  bd.BadgePosition.topEnd(top: -12, end: 10),
                              // badgeColor: Theme.of(context).primaryColor,
                              // padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder: (_, index) {
                                    var project = projects.elementAt(index);
                                    return GestureDetector(
                                      onTap: () async {
                                        await widget.prefsOGx.saveProject(project);
                                        widget.onSelected(project);
                                      },
                                      child: Card(
                                        shape: getRoundedBorder(radius: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 4,
                                                width: 4,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  project.name!,
                                                  style:
                                                      myTextStyleSmall(context),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}

class ProjectDropDown extends StatelessWidget {
  const ProjectDropDown(
      {Key? key,
      required this.onSelected,
      required this.title,
      required this.height,
      required this.width,
      required this.projects,
      required this.sortByDate,
      this.padding})
      : super(key: key);
  final Function(Project) onSelected;
  final String title;
  final double height;
  final double width;
  final List<Project> projects;
  final bool sortByDate;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    var items = <DropdownMenuItem<Project>>[];
    if (sortByDate) {
      projects.sort((a, b) => b.created!.compareTo(a.created!));
    } else {
      projects.sort((a, b) => a.name!.compareTo(b.name!));
    }
    return Padding(
      padding: EdgeInsets.all(padding ?? 8.0),
      child: DropdownButton(items: items, onChanged: onChanged),
    );
  }

  void onChanged(value) {
    onSelected(value);
  }
}
