import 'package:flutter/material.dart';

import '../../bloc/organization_bloc.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../functions.dart';
import 'generic_message.dart';

class MessageMobile extends StatefulWidget {
  final User? user;

  const MessageMobile({Key? key,  this.user}) : super(key: key);
  @override
  MessageMobileState createState() => MessageMobileState();
}

class MessageMobileState extends State<MessageMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _key = GlobalKey<ScaffoldState>();
  List<Project> _projects = [];

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getProjects(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getProjects(bool force) async {
    if (widget.user!.userType == UserType.fieldMonitor) {
      setState(() {
        _genericMessage = true;
      });
      return;
    }
    setState(() {
      busy = true;
    });
    _projects = await organizationBloc.getOrganizationProjects(
        organizationId: widget.user!.organizationId!, forceRefresh: force);
    setState(() {
      busy = false;
    });
  }

  Project? _selectedProject;
  bool _genericMessage = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Digital Monitor Messaging',
          style: myTextStyleMedium(context),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(_genericMessage ? 100 : 100),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                        _genericMessage ? 'Generic Message' : 'Project Message', style: myTextStyleSmall(context),),
                    const SizedBox(
                      width: 20,
                    ),
                    Switch(value: _genericMessage, onChanged: _onSwitchChanged),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                Text(
                  '${widget.user!.name}',
                  style: myTextStyleMedium(context),
                ),
                const SizedBox(
                  height: 24,
                ),

              ],
            ),
        ),
      ),
      body: Stack(
              children: [
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Card(
                      elevation: 8,
                      child: SingleChildScrollView(
                          child: GenericMessage(
                              project: _selectedProject == null? null: _selectedProject!, user: widget.user!))),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        var p = _projects.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedProject = p;
                            });
                          },
                          child: Card(
                            child: ListTile(
                              title: Text('${p.name}'),
                              leading: Icon(
                                Icons.app_registration,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            )

    ));
  }

  void _onSwitchChanged(bool value) {
    pp('MessageMobile: 💙 💙 💙 _onSwitchChanged  💙 $value');
    setState(() {
      _genericMessage = value;
    });
  }
}
