import 'package:flutter/material.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/question.dart';
import '../../library/data/questionnaire.dart';
import '../../library/data/section.dart';
import '../../library/functions.dart';


class SectionEditor extends StatefulWidget {
  final Questionnaire questionnaire;

  const SectionEditor(this.questionnaire, {super.key});

  @override
  SectionEditorState createState() => SectionEditorState();
}

class SectionEditorState extends State<SectionEditor>
    implements SectionFormListener {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Section> sections = [];

  @override
  void initState() {
    super.initState();
    sections = widget.questionnaire.sections;
    prettyPrint(widget.questionnaire.toJson(),
        '🎲 🎲 🎲 SectionEditor: 🧩🧩 Questionnaire, check sections');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Section Editor'),
        backgroundColor: Colors.pink[300],
        elevation: 8,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    widget.questionnaire.title,
                    style: Styles.whiteSmall,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        '${sections.length}',
                        style: Styles.blackBoldLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Sections',
                        style: Styles.whiteSmall,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (BuildContext context, int index) {
            var section = sections.elementAt(index);
            return SectionForm(section, this, widget.questionnaire);
          },
        ),
      ),
    );
  }

  @override
  onSectionChanged(Section section) async {
    pp(
        '🥏🥏🥏 onSectionChanged ... update questionnaire, check if updated in place ???');
    prettyPrint(section.toJson(),
        ' 🥬🥬🥬 Section just received,  🥬  check if section is in  questionnaire already');
    prettyPrint(widget.questionnaire.toJson(),
        'Questionnaire, 🍪🍪🍪 check if section updated');
    // await prefsOGx.saveQuestionnaire(widget.questionnaire);
    // adminBloc.updateActiveQuestionnaire(widget.questionnaire);
  }
}

abstract class SectionFormListener {
  onSectionChanged(Section section);
}

class SectionForm extends StatefulWidget {
  final Section section;
  final Questionnaire questionnaire;
  final SectionFormListener listener;
  const SectionForm(this.section, this.listener, this.questionnaire, {super.key});

  @override
  SectionFormState createState() => SectionFormState();
}

class SectionFormState extends State<SectionForm> {
  @override
  void initState() {
    super.initState();
    secController.text = widget.section.sectionNumber!;
    titleController.text = widget.section.title!;
    descController.text = widget.section.description!;
    title = widget.section.title!;
    description = widget.section.description!;
    widget.section.questions ??= [];
    numberOfQuestions = widget.section.questions!.length;
    if (numberOfQuestions == 0) numberOfQuestions = 1;
    countController.text = '$numberOfQuestions';
  }

  @override
  Widget build(BuildContext context) {
    pp('_SectionFormState build ....');
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 4,
            ),
            TextField(
              onChanged: _onSectionNumber,
              controller: secController,
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              decoration: const InputDecoration(
                labelText: 'Section',
                hintText: 'Section Name/Number',
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              onChanged: _onTitle,
              controller: titleController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter Section Title',
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              onChanged: _onDescription,
              controller: descController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter Section  Description',
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              onChanged: _onCountChanged,
              controller: countController,
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              decoration: const InputDecoration(
                labelText: 'Number of Questions',
                hintText: 'Enter Number of Questions',
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(

              onPressed: _navigateToQuestionEditor,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 28.0, right: 28, top: 8, bottom: 8),
                child: Text(
                  'Edit Questions',
                  style: Styles.whiteSmall,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuestionEditor() async {
    if (numberOfQuestions == 0) {
      pp(
          '_navigateToQuestionEditor ........numberOfQuestions: $numberOfQuestions');
      return;
    }
    if (widget.section.questions == null || widget.section.questions!.isEmpty) {
      var list = <Question>[];
      for (var i = 0; i < numberOfQuestions; i++) {
        list.add(Question(
          text: 'Question ${i + 1} - please edit',
          questionType: 'SingleAnswer',
          answers: [],
          choices: [],
        ));
      }
      widget.section.questions = list;
    } else {
      if (numberOfQuestions > widget.section.questions!.length) {
        var num = numberOfQuestions - widget.section.questions!.length;
        for (var i = 0; i < num; i++) {
          widget.section.questions!.add(Question(
            questionType: 'SingleAnswer',
            text: 'Question #${i + 1} -please edit',
            answers: [],
            choices: [],
          ));
        }
      }
    }
    if (title == null || title!.isEmpty) {
      pp('_navigateToQuestionEditor : title.isEmpty');
      return;
    }
    if (description == null || description!.isEmpty) {
      pp('_navigateToQuestionEditor : description.isEmpty');
      return;
    }

    widget.section.title = title;
    widget.section.description = description;
    widget.listener.onSectionChanged(widget.section);

    prettyPrint(widget.section.toJson(),
        '🌽 Section before navigating to 🌽🌽  QuestionEditor');

    // Navigator.push(
    //     context,
    //     SlideRightRoute(
    //         widget: QuestionEditor(widget.section, widget.questionnaire)));
  }

  TextEditingController secController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController countController = TextEditingController();
  String? title, description, sectionNumber;
  int numberOfQuestions = 1;

  void _onSectionNumber(String value) {
    sectionNumber = value;
    widget.section.sectionNumber = sectionNumber;
    widget.listener.onSectionChanged(widget.section);
  }

  void _onTitle(String value) {
    title = value;
    widget.section.title = title;
    widget.listener.onSectionChanged(widget.section);
  }

  void _onDescription(String value) {
    description = value;
    widget.section.description = description;
    widget.listener.onSectionChanged(widget.section);
  }

  void _onCountChanged(String value) {
    numberOfQuestions = int.parse(value);
  }
}
