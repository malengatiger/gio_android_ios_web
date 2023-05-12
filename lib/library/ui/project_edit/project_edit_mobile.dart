import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/prefs_og.dart';
import '../../bloc/organization_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../functions.dart';

class ProjectEditMobile extends StatefulWidget {
  final Project? project;
  const ProjectEditMobile(this.project, {super.key});

  @override
  ProjectEditMobileState createState() => ProjectEditMobileState();
}

class ProjectEditMobileState extends State<ProjectEditMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var nameController = TextEditingController();
  var descController = TextEditingController();
  var maxController = TextEditingController(text: '500');
  var isBusy = false;

  User? admin;
  final _formKey = GlobalKey<FormState>();

  String? projectEditor, projectName, description, maximumMonitoringDistance, submitProject,
  newProject, editProject, enterProjectName, addProjectLocations,
      enterDescription, enterDistance, descriptionOfProject;

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

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _setup();
    _getUser();
  }

  void _getUser() async {
    admin = await prefsOGx.getUser();
    if (admin != null) {
      pp('🎽 🎽 🎽 We have an admin user? 🎽 🎽 🎽 ${admin!.name!}');
      setState(() {});
    }
  }

  void _setup() {
    if (widget.project != null) {
      nameController.text = widget.project!.name!;
      descController.text = widget.project!.description!;
      maxController.text = '${widget.project!.monitorMaxDistanceInMetres}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isBusy = true;
      });
      try {
        Project mProject;
        if (widget.project == null) {
          pp('😡 😡 😡 _submit new project ......... ${nameController.text}');
          var uuid = const Uuid();
          final sett = await cacheManager.getSettings();
          final projectAddedToOrganization = await translator.translate('projectAddedToOrganization', sett!.locale!);
          final messageFromGeo = await getFCMMessageTitle();
          mProject = Project(
              name: nameController.text,
              description: descController.text,
              organizationId: admin!.organizationId!,
              organizationName: admin!.organizationName!,
              created: DateTime.now().toUtc().toIso8601String(),
              monitorMaxDistanceInMetres: double.parse(maxController.text),
              translatedTitle: messageFromGeo,
              translatedMessage: projectAddedToOrganization,
              photos: [],
              videos: [],
              communities: [],
              monitorReports: [],
              nearestCities: [],
              projectPositions: [],
              ratings: [],
              projectId: uuid.v4());
          var m = await projectBloc.addProject(mProject);
          pp('🎽 🎽 🎽 _submit: new project added .........  ${m.toJson()}');
        } else {
          pp('😡 😡 😡 _submit existing project for update, soon! 🌸 ......... ');
          widget.project!.name = nameController.text;
          widget.project!.description = descController.text;
          mProject = widget.project!;
          var m = await projectBloc.updateProject(widget.project!);
          pp('🎽 🎽 🎽 _submit: new project updated .........  ${m.toJson()}');
        }
        setState(() {
          isBusy = false;
        });
        organizationBloc.getOrganizationProjects(
            organizationId: mProject.organizationId!, forceRefresh: true);
        _navigateToProjectLocation(mProject);
      } catch (e) {
        setState(() {
          isBusy = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _navigateToProjectLocation(Project mProject) async {
    pp(' 😡 _navigateToProjectLocation  😡 😡 😡 ${mProject.name}');
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomRight,
            duration: const Duration(seconds: 1),
            child: ProjectMapMobile(project: mProject)));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(projectEditor == null?
            'Project Editor': projectEditor!,
            style: myTextStyleLarge(context),
          ),
          actions: [
            widget.project == null
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      if (widget.project != null) {
                        _navigateToProjectLocation(widget.project!);
                      }
                    },
                  )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                Text(
                  widget.project == null ? newProject == null?'New Project': newProject! : editProject == null?
                  'Edit Project': editProject!,
                  style: myTextStyleMedium(context),
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  admin == null ? '' : admin!.organizationName!,
                  style: myTextStyleLargerPrimaryColor(context),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        // backgroundColor: Colors.brown[100],
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.lato(
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.event,
                              color: Theme.of(context).primaryColor,
                            ),
                            labelText: projectName == null?
                            'Project Name': projectName!,
                            hintText: enterProjectName == null?
                            'Enter Project Name': enterProjectName!),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return enterProjectName == null?
                            'Please enter Project name': enterProjectName!;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: descController,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.lato(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            fontWeight: FontWeight.normal),
                        minLines: 2, //Normal textInputField will be displayed
                        maxLines:
                            6, // when user presses enter it will adapt to it
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            labelText: descriptionOfProject == null?
                            'Description':descriptionOfProject!,
                            hintText: 'Enter Description'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return enterDescription == null?
                            'Please enter Description': enterDescription!;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.camera_enhance_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            labelText: maximumMonitoringDistance == null?
                            'Max Monitor Distance in Metres': maximumMonitoringDistance!,
                            hintText: enterDistance == null?
                                'Enter Maximum Monitor Distance in metres': enterDistance!),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return enterDistance == null?
                            'Please enter Maximum Monitor Distance in Metres': enterDistance!;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      isBusy
                          ? const SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 8,
                                backgroundColor: Colors.black,
                              ),
                            )
                          : Column(
                              children: [
                                widget.project == null
                                    ? Container()
                                    : SizedBox(
                                        width: 220,
                                        child: ElevatedButton(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(addProjectLocations == null?
                                              'Add Project Location':addProjectLocations!,
                                              style: Styles.whiteSmall,
                                            ),
                                          ),
                                          onPressed: () {
                                            _navigateToProjectLocation(
                                                widget.project!);
                                          },
                                        ),
                                      ),
                                widget.project == null
                                    ? Container()
                                    : const SizedBox(
                                        height: 20,
                                      ),
                                SizedBox(
                                  width: 220,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(submitProject == null?
                                        'Submit Project': submitProject!,
                                        style: myTextStyleMedium(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
