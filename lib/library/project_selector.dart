import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';

import 'data/project.dart';
import 'functions.dart';

class ProjectSelector extends StatefulWidget {
  const ProjectSelector({Key? key, required this.onSelected}) : super(key: key);
  final Function(Project) onSelected;
  @override
  ProjectSelectorState createState() => ProjectSelectorState();
}

class ProjectSelectorState extends State<ProjectSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var projects = <Project>[];
  bool busy = false;
  var items = <DropdownMenuItem<Project>>[];

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _getProjects(false);
  }

  void _getProjects(bool forceRefresh) async {
    var user = await prefsOGx.getUser();
    if (user == null) {
      return;
    }
    setState(() {
      busy = true;
    });
    try {
      projects = await organizationBloc
          .getOrganizationProjects(organizationId: user.organizationId!,
          forceRefresh: forceRefresh);
      for (var value in projects) {
        items.add(DropdownMenuItem(
            value: value,
            child: Text(value.name!, style: const TextStyle(fontSize: 12),)));
      }
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        hint: Text('Select Project', style: myTextStyleMedium(context),),
        items: items, onChanged: onChanged);
  }

  void onChanged(Project? p) {
    if (p != null) {
      widget.onSelected(p);
    }
  }
}
