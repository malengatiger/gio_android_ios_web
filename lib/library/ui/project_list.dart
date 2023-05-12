import 'package:flutter/material.dart';

import '../api/data_api_og.dart';
import '../api/prefs_og.dart';
import '../data/user.dart';
import '../data/project.dart';
import '../functions.dart';
abstract class ProjectListener {
  onProjectSelected(Project project);
}

class ProjectList extends StatefulWidget {
  final ProjectListener listener;

  const ProjectList(this.listener, {super.key});

  @override
  ProjectListState createState() => ProjectListState();
}

class ProjectListState extends State<ProjectList> {
  User? user;
  bool isBusy = false;
  List<Project> projects = [];
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    user = await prefsOGx.getUser();
    setState(() {
      isBusy = true;
    });
    projects = await dataApiDog.findProjectsByOrganization(user!.organizationId!);
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Project List',
          style: Styles.whiteSmall,
        ),
        elevation: 8,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        user == null ? 'Organization' : user!.organizationName!,
                        style: Styles.whiteBoldSmall,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          '${projects.length}',
                          style: Styles.blackBoldLarge,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Projects',
                          style: Styles.whiteSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 24,
                backgroundColor: Colors.yellow,
              ),
            )
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                var p = projects.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: GestureDetector(
                    onTap: () {
                      widget.listener.onProjectSelected(p);
                    },
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12, top: 8),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.apps,
                                  color: getRandomColor(),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: Text(p.name!,
                                        style: Styles.blackBoldMedium,
                                        overflow: TextOverflow.clip)),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 32,
                                ),
                                Expanded(
                                    child: Text(p.description!,
                                        style: Styles.blackSmall,
                                        overflow: TextOverflow.clip)),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
