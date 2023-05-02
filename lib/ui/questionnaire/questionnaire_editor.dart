import 'dart:async';

import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/questionnaire.dart';
import '../../library/data/section.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import 'section_editor.dart';

class QuestionnaireEditor extends StatefulWidget {
  final Questionnaire? questionnaire;

  const QuestionnaireEditor({super.key, this.questionnaire});

  @override
  QuestionnaireEditorState createState() => QuestionnaireEditorState();
}

class QuestionnaireEditorState extends State<QuestionnaireEditor>
     {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController sectionsController = TextEditingController();
  User? user;
  Questionnaire? questionnaire;
  bool showButton = false;
  late StreamSubscription<Questionnaire> subscription;


  @override
  void initState() {
    super.initState();
    if (widget.questionnaire != null) {
      titleController.text = widget.questionnaire!.title;
      descController.text = widget.questionnaire!.description;
      sectionsController.text = '${widget.questionnaire!.sections.length}';
      title = widget.questionnaire!.title;
      description = widget.questionnaire!.description;
      numberOfSections = widget.questionnaire!.sections.length;
      questionnaire = widget.questionnaire;
    }
    _getUser();
    _subscribe();
  }

  _subscribe() {
    subscription = adminBloc.activeQuestionnaireStream.listen((snapshot) {
      debugPrint(
          '🛳 🛳 🛳 subscription listener fired, 🎽 active questionnaire arrived: $snapshot');
      setState(() {
        questionnaire = snapshot;
      });
    });
  }

  _getUser() async {
    // user = await prefsOGx.getUser();
    // questionnaire = await prefsOGx.getQuestionnaire();
    // if (questionnaire != null) {
    //   titleController.text = questionnaire!.title;
    //   descController.text = questionnaire!.description;
    //   sectionsController.text = '${questionnaire!.sections.length}';
    //   title = questionnaire!.title;
    //   description = questionnaire!.description;
    //   numberOfSections = questionnaire!.sections.length;
    //   setState(() {
    //     showButton = true;
    //   });
    // } else {
    //   // questionnaire = Questionnaire(
    //   //   title: 'New Questionnaire',
    //   //   description: 'Please edit',
    //   // );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Questionnaire Editor'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(showButton ? 120 : 80),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                showButton == false
                    ? Text(
                        'New Questionnaire',
                        style: Styles.blackBoldMedium,
                      )
                    : Text('${questionnaire?.title}',
                        style: Styles.blackBoldMedium),
                const SizedBox(
                  height: 20,
                ),
                showButton
                    ? ElevatedButton(
                        onPressed: _writeQuestionnaireToDatabase,
                        child: Text(
                          'Submit New Questionnaire',
                          style: Styles.whiteSmall,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 24,
                  backgroundColor: Colors.teal[700],
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 24,
                          ),
                          Text('Questionnaire Details',
                              style: Styles.blackBoldMedium),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            onChanged: _onTitle,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter Questionnaire Title',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            onChanged: _onDescription,
                            keyboardType: TextInputType.multiline,
                            controller: descController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter Questionnaire Description',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            onChanged: _onSections,
                            controller: sectionsController,
                            keyboardType:
                                const TextInputType.numberWithOptions(signed: false),
                            decoration: const InputDecoration(
                              labelText: 'Number of Sections',
                              hintText: 'Number of Questionnaire Sections',
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: _processFirstQuestionnairePart,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 28.0, right: 28),
                              child: Text(
                                'Edit Sections',
                                style: Styles.whiteSmall,
                              ),
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
              ],
            ),
    );
  }

  String? title, description;
  int numberOfSections = 1;

  void _onTitle(String value) async {
    title = value;
    questionnaire?.title = title!;
    // await prefsOGx.saveQuestionnaire(questionnaire!);
    // adminBloc.updateActiveQuestionnaire(questionnaire!);
  }

  void _onDescription(String value) async {
    description = value;
    questionnaire?.description = description!;
    // await prefsOGx.saveQuestionnaire(questionnaire!);
    // adminBloc.updateActiveQuestionnaire(questionnaire!);
  }

  void _onSections(String value) {
    numberOfSections = int.parse(value);
  }

  bool isBusy = false;
  void _processFirstQuestionnairePart() async {
    setState(() {
      isBusy = true;
    });
    if (title == null || title!.isEmpty) {
      _showErrorSnack('💦 💦 Enter Title');
    }
    if (description == null || description!.isEmpty) {
      _showErrorSnack('💦 💦 Enter Description');
    }
    var country = await prefsOGx.getCountry();
    if (country == null) {
      //todo - get appropriate country
      // country = Country(
      //   name: 'South Africa',
      //   countryCode: 'ZA', population: 0,
      // );
      // country.countryId = '5d1f4e0d41ec6bc61c3c3189';
    }

    questionnaire ??= Questionnaire(title: title!,
        name: 'Questionnaire name', organizationId: user!.organizationId!,
        description: description!,
        organizationName: user!.organizationName!,
         created: DateTime.now().toUtc().toIso8601String(),
        countryName: '', sections: []);


    //add  number of sections
    if (numberOfSections == 0) {
      numberOfSections = 1;
    }
    if (questionnaire!.sections.isEmpty) {
      for (var i = 0; i < numberOfSections; i++) {
        var sec = Section(
          sectionNumber: '${i + 1}',
          title: 'Section ${i + 1} Title',
          sectionId: const Uuid().v4().toString(),
          description: 'Description of Section ${i+1}',
        );
        questionnaire!.sections.add(sec);
      }
    } else {
      pp('⛱⛱ sections exist, ⛱ templates may not be necessary');
      if (numberOfSections - questionnaire!.sections.length > 0) {
        var number = numberOfSections - questionnaire!.sections.length;
        pp('⛱⛱ sections exist, ⛱ but extra $number templates are necessary');
        for (var i = 0; i < number; i++) {
          var sec = Section(
            sectionNumber: '${i + 1 + questionnaire!.sections.length}',
            title: 'Section ${i + 1 + questionnaire!.sections.length} Title',
              sectionId: const Uuid().v4().toString(),
              description: 'Description of Section ${i+1}'
          );
          questionnaire!.sections.add(sec);
        }
      }
    }
    setState(() {
      isBusy = false;
    });

    // await prefsOGx.saveQuestionnaire(questionnaire!);
    // adminBloc.updateActiveQuestionnaire(questionnaire!);

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: SectionEditor(questionnaire!)));
    }
  }

  void _showErrorSnack(String s) {
    showToast(message: s, context: context);

  }


  void _writeQuestionnaireToDatabase() async {
    if (isBusy) return;
    setState(() {
      isBusy = true;
    });
    debugPrint(
        '\n\n🦠 🦠 🦠 🦠 About to add  questionnaire to DB: 🦠 🦠 🦠 🦠 🦠 ');
    //prettyPrint(questionnaire?.toJson(),
      //  '... 🍎 🍎 🍎 about add this questionnaire to Mongo: 🍎 ');
    try {
      await adminBloc.addQuestionnaire(questionnaire!);
      debugPrint(
          ' 😍  😍  😍  remove active 💦 questionnaire from prefs after good write  😍 ');
      // prefsOGx.removeQuestionnaire();
      setState(() {
        isBusy = false;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      pp(e);
      _showErrorSnack('$e');
    }
  }
}
