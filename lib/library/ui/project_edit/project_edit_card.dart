import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/translation_handler.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../data/user.dart';

class ProjectEditCard extends StatefulWidget {
  const ProjectEditCard(
      {Key? key,
      required this.project,
      this.width,
      required this.navigateToLocation})
      : super(key: key);

  final Project? project;
  final double? width;
  final Function(Project) navigateToLocation;

  @override
  ProjectEditCardState createState() => ProjectEditCardState();
}

class ProjectEditCardState extends State<ProjectEditCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var descController = TextEditingController();
  var maxController = TextEditingController();
  bool busy = false;
  User? admin;
  String? projectEditor, projectName, description, maximumMonitoringDistance, submitProject,
      newProject, editProject, enterProjectName, addProjectLocations,
      enterDescription, enterDistance, descriptionOfProject;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _setControllers();
    _getUser();
  }
  void _setControllers() {
    if (widget.project != null) {
      nameController = TextEditingController(text: widget.project!.name!);
      descController = TextEditingController(text: widget.project!.description!);
      maxController = TextEditingController(text: '${widget.project!.monitorMaxDistanceInMetres!}');
    }
  }
  Future _setTexts() async {
    final sett = await prefsOGx.getSettings();
    projectEditor = await translator.translate('projectEditor', sett.locale!);

    projectName = await translator.translate('projectName', sett.locale!);
    newProject = await translator.translate('newProject', sett.locale!);
    enterProjectName = await translator.translate('enterProjectName', sett.locale!);
    enterDescription = await translator.translate('enterDescription', sett.locale!);
    descriptionOfProject = await translator.translate('descriptionOfProject', sett.locale!);
    submitProject = await translator.translate('submitProject', sett.locale!);
    editProject = await translator.translate('editProject', sett.locale!);
    enterDistance = await translator.translate('enterDistance', sett.locale!);
    addProjectLocations = await translator.translate('addProjectLocations', sett.locale!);

    maximumMonitoringDistance = await translator.translate('maximumMonitoringDistance', sett.locale!);

    setState(() {

    });
  }


  void _getUser() async {
    admin = await prefsOGx.getUser();

    setState(() {

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Project? project;
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        busy = true;
      });
      try {
        var dist = double.parse(maxController.text);
        if (widget.project == null) {
          pp('😡 😡 😡 _submit new project ......... ${nameController.text}');
          var uuid = const Uuid();
          final sett = await cacheManager.getSettings();
          final projectAddedToOrganization = await translator.translate('projectAddedToOrganization', sett.locale!);
          final messageFromGeo = await getFCMMessageTitle();
          project = Project(
              name: nameController.text,
              description: descController.text,
              organizationId: admin!.organizationId!,
              organizationName: admin!.organizationName!,
              created: DateTime.now().toUtc().toIso8601String(),
              monitorMaxDistanceInMetres: dist,
              translatedMessage: projectAddedToOrganization,
              translatedTitle: messageFromGeo,
              photos: [],
              videos: [],
              communities: [],
              monitorReports: [],
              nearestCities: [],
              projectPositions: [],
              ratings: [],
              projectId: uuid.v4());
          project = await projectBloc.addProject(project!);
          pp('🎽 🎽 🎽 _submit: new project added .........  ${project!.toJson()}');
        } else {
          pp('😡 😡 😡 _submit existing project for update, soon! 🌸 ......... ');

          widget.project!.name = nameController.text;
          widget.project!.description = descController.text;

          widget.project!.monitorMaxDistanceInMetres = dist;
          project = widget.project;

          var m = await projectBloc.updateProject(widget.project!);
          pp('🎽 🎽 🎽 _submit: new project updated .........  ${m.toJson()}');
        }

        /// refresh data from backend ...
        ///
        var map = await getStartEndDates();
        final startDate = map['startDate'];
        final endDate = map['endDate'];
        await projectBloc.getProjectData(
            projectId: project!.projectId!,
            forceRefresh: true,
            startDate: startDate!,
            endDate: endDate!);

        ///a chance to create locations for the project
        widget.navigateToLocation(project!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('Failed: $e')));
        }
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: widget.width ?? width,
      child: Card(
        elevation: 4,
        shape: getRoundedBorder(radius: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      style: myTextStyleMedium(context),
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.event,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: projectName == null? 'Project Name': projectName!,
                          hintText: enterProjectName == null?'Enter Project Name': enterProjectName!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return enterProjectName == null?'Please enter Project name': enterProjectName!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: descController,
                      keyboardType: TextInputType.multiline,
                      style: myTextStyleMedium(context),
                      minLines: 4, //Normal textInputField will be displayed
                      maxLines:
                          6, // when user presses enter it will adapt to it
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: descriptionOfProject == null?
                          'Description of the Project': descriptionOfProject!,
                          hintText: 'Enter Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return descriptionOfProject == null?
                          'Please enter Description': descriptionOfProject!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      style: myTextStyleMedium(context),
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.camera_enhance_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: maximumMonitoringDistance == null?
                          'Max Monitor Distance in Metres': maximumMonitoringDistance!,
                          hintText: maximumMonitoringDistance == null?
                          'Enter Maximum Monitor Distance in metres': maximumMonitoringDistance!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return maximumMonitoringDistance == null?
                          'Please enter Maximum Monitor Distance in Metres': maximumMonitoringDistance!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: Colors.pink,
                            ),
                          )
                        : Column(
                            children: [
                              const SizedBox(
                                height: 24,
                              ),
                              project == null
                                  ? const SizedBox()
                                  : SizedBox(
                                      width: 400,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              widget
                                                  .navigateToLocation(project!);
                                            },
                                            icon: Icon(
                                              Icons.location_on,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          project == null
                                              ? const SizedBox()
                                              : ElevatedButton(
                                                  child: Text(addProjectLocations == null?
                                                    'Add Project Locations': addProjectLocations!,
                                                    style: myTextStyleMedium(
                                                        context),
                                                  ),
                                                  onPressed: () {
                                                    widget.navigateToLocation(
                                                        project!);
                                                  },
                                                ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(
                                height: 24,
                              ),
                              SizedBox(
                                width: 220,
                                child: project == null
                                    ? ElevatedButton(
                                        onPressed: _submit,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(submitProject == null?
                                            'Submit Project': submitProject!,
                                            style: myTextStyleMedium(context),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
