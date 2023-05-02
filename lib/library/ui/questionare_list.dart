import 'package:flutter/material.dart';

import '../api/data_api.dart';
import '../api/prefs_og.dart';
import '../bloc/admin_bloc.dart';
import '../data/user.dart';
import '../data/questionnaire.dart';
import '../functions.dart';

class QuestionnaireList extends StatefulWidget {
  final QuestionnaireListener listener;

  const QuestionnaireList(this.listener, {super.key});

  @override
  QuestionnaireListState createState() => QuestionnaireListState();
}

class QuestionnaireListState extends State<QuestionnaireList> {
  List<Questionnaire> questionnaires = [];
  bool isBusy = false;
  User? user;
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      isBusy = true;
    });
    user = await prefsOGx.getUser();
    if (user != null) {
      questionnaires =
          await DataAPI.getQuestionnairesByOrganization(user!.organizationId!);
    }
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Questionnaire>>(
        stream: adminBloc.questionnaireStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            questionnaires = snapshot.data!;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Questionnaires',
                style: Styles.whiteSmall,
              ),
              backgroundColor: Colors.purple[300],
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _getData,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(160),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              user == null ? '' : '${user!.organizationName}',
                              style: Styles.whiteBoldSmall,
                              overflow: TextOverflow.clip,
                            )),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  '${questionnaires.length}',
                                  style: Styles.blackBoldLarge,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Questionnaires',
                                  style: Styles.whiteSmall,
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.brown[50],
            body: isBusy
                ? const Center(
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 28,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: questionnaires.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: GestureDetector(
                          onTap: () {
                            widget.listener.onQuestionnaireSelected(
                                questionnaires.elementAt(index));
                          },
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                        child: Text(
                                          questionnaires.elementAt(index).title,
                                          style: Styles.blackBoldSmall,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        width: 32,
                                      ),
                                      Expanded(
                                        child: Text(
                                          questionnaires.elementAt(index).description,
                                          style: Styles.blackSmall,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
//                              ListTile(
//                                leading: Icon(Icons.apps),
//                                title: Text(
//                                  '${questionnaires.elementAt(index).title}',
//                                  style: Styles.blackBoldSmall,
//                                ),
//                                subtitle: Text(
//                                    '${questionnaires.elementAt(index).description}'),
//                              ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        });
  }
}

abstract class QuestionnaireListener {
  onQuestionnaireSelected(Questionnaire questionnaire);
}
