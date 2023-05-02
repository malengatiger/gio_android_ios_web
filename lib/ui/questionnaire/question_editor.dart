import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/question.dart';
import '../../library/data/questionnaire.dart';
import '../../library/data/section.dart';
import '../../library/functions.dart';
import 'choice_editor.dart';

class QuestionEditor extends StatefulWidget {
  final Section section;
  final Questionnaire questionnaire;

  const QuestionEditor(this.section, this.questionnaire, {super.key});

  @override
  QuestionEditorState createState() => QuestionEditorState();
}

class QuestionEditorState extends State<QuestionEditor>
    implements QuestionFormListener {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Question> questions = [];
  @override
  void initState() {
    super.initState();
    questions = widget.section.questions!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Question Editor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${widget.section.title}',
                    style: Styles.whiteBoldMedium,
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        '${questions.length}',
                        style: Styles.blackBoldLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Questions',
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
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (BuildContext context, int index) {
            return QuestionForm(
                questions.elementAt(index), index, this, widget.questionnaire);
          },
        ),
      ),
    );
  }

  @override
  onQuestionChanged(Question question, int index) async {
    debugPrint('🦋🦋🦋 onQuestionChanged:  index $index  ');
    prettyPrint(question.toJson(),
        '🦋🦋🦋 Question after update, ☘☘ check if ok inside questionnaire');
    prettyPrint(widget.questionnaire.toJson(),
        '🐤 🐤 Questionnaire after question update, ☘☘ check  question');

    // await prefsOGx.saveQuestionnaire(widget.questionnaire);
    // adminBloc.updateActiveQuestionnaire(widget.questionnaire);
    return null;
  }
}

class QuestionForm extends StatefulWidget {
  final Question question;
  final int index;
  final Questionnaire questionnaire;
  final QuestionFormListener listener;
  const QuestionForm(this.question, this.index, this.listener, this.questionnaire, {super.key});

  @override
  QuestionFormState createState() => QuestionFormState();
}

class QuestionFormState extends State<QuestionForm> {
  TextEditingController textController = TextEditingController();
  TextEditingController countController = TextEditingController();
  @override
  void initState() {
    super.initState();
    widget.question.choices?.forEach((m) {
      pp('choice :  $m');
    });
    textController.text = widget.question.text!;
    countController.text = '${widget.question.choices?.length}';
    switch (widget.question.questionType) {
      case 'SingleAnswer':
        picked = 'Single Answer';
        break;
      case 'MultipleChoice':
        picked = 'Multiple Choice';
        isChoices = true;
        break;
      case 'SingleChoice':
        picked = 'Single Choice';
        isChoices = true;
        break;
    }
  }

  String? picked;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          Text(
            'Question ${widget.index + 1}',
            style: Styles.blackBoldMedium,
          ),
          const SizedBox(
            height: 12,
          ),
          // RadioButtonGroup(
          //   labels: const <String>[
          //     'Single Answer',
          //     'Multiple Choice',
          //     'Single Choice',
          //   ],
          //   picked: picked,
          //   onChange: _onRadioButton,
          // ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8),
            child: TextField(
              onChanged: _onTextChange,
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Enter Question Text',
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: isChoices
                ? Column(
                    children: <Widget>[
                      TextField(
                        onChanged: _onChoices,
                        controller: countController,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: false),
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Number of Choices',
                          hintText: 'Enter Number of Choices',
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ElevatedButton(
                        // elevation: 4,
                        // color: Colors.indigo,
                        onPressed: () {
                          _navigateToChoiceEditor(context);
                        },
                        child: Text(
                          'Edit Choices',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  bool isChoices = false;
  String text = '';
  void _onTextChange(String value) {
    text = value;
    widget.question.text = text;
    widget.listener.onQuestionChanged(widget.question, widget.index);
  }

  void _onRadioButton(String label, int index) {
    pp('🦕 🦕 🦕 🦕 _onRadioButton  $label index :  $index');
    switch (index) {
      case 0:
        widget.question.questionType = 'SingleAnswer';
        setState(() {
          isChoices = false;
        });
        break;
      case 1:
        widget.question.questionType = 'MultipleChoice';
        setState(() {
          isChoices = true;
        });
        break;
      case 2:
        widget.question.questionType = 'SingleChoice';
        setState(() {
          isChoices = true;
        });
        break;
    }
    widget.listener.onQuestionChanged(widget.question, widget.index);
  }

  int numberOfChoices = 0;
  void _onChoices(String value) {
    numberOfChoices = int.parse(value);
  }

  void _navigateToChoiceEditor(BuildContext context) async {
    pp('_navigateToChoiceEditor, 🚨 🚨 🚨 check choices ...');
    pp(widget.question.choices);
    if (widget.question.choices == null || widget.question.choices!.isEmpty) {
      List<String> list = [];
      for (var i = 0; i < numberOfChoices; i++) {
        list.add('Choice #${i + 1} - please edit');
      }
      widget.question.choices = list;
    } else {
      if (numberOfChoices > widget.question.choices!.length) {
        var num = numberOfChoices - widget.question.choices!.length;
        for (var i = 0; i < num; i++) {
          widget.question.choices
              ?.add('Choice #${i + 1 + numberOfChoices} - please edit');
        }
      }
    }
    // await prefsOGx.saveQuestionnaire(widget.questionnaire);
    // adminBloc.updateActiveQuestionnaire(widget.questionnaire);

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: ChoiceEditor(widget.question, widget.questionnaire)));
    }
  }
}

abstract class QuestionFormListener {
  onQuestionChanged(Question question, int index);
}
