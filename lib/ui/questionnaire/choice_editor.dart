import 'package:flutter/material.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/question.dart';
import '../../library/data/questionnaire.dart';
import '../../library/functions.dart';


class ChoiceEditor extends StatefulWidget {
  final Question question;
  final Questionnaire questionnaire;
  const ChoiceEditor(this.question, this.questionnaire, {super.key});

  @override
  ChoiceEditorState createState() => ChoiceEditorState();
}

class ChoiceEditorState extends State<ChoiceEditor>
    implements ChoiceFormListener {
  List<String> choices = [];
  TextEditingController textEditingController = TextEditingController();
  @override
  initState() {
    super.initState();
    choices = widget.question.choices!;
    pp('$choices choices found in question');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choices Editor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${widget.question.text}',
                        style: Styles.whiteMedium,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '${choices.length}',
                            style: Styles.blackBoldLarge,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Choices',
                            style: Styles.whiteSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: choices.length,
          itemBuilder: (BuildContext context, int index) {
            return ChoiceForm(choices.elementAt(index), index, this);
          },
        ),
      ),
    );
  }

  @override
  onTextChange(String text, int index) async {
    pp('🐼 🐼 🐼 🐼 onTextChange: 🧩 $text for choice 🧩 #${index + 1} 🧩 will update active questionnaire');
    setState(() {
      choices[index] = text;
      widget.question.choices = choices;
    });

    // await prefsOGx.saveQuestionnaire(widget.questionnaire);
    // adminBloc.updateActiveQuestionnaire(widget.questionnaire);
  }
}

abstract class ChoiceFormListener {
  onTextChange(String text, int index);
}

class ChoiceForm extends StatefulWidget {
  final String choice;
  final int index;
  final ChoiceFormListener listener;
  const ChoiceForm(this.choice, this.index, this.listener, {super.key});

  @override
  ChoiceFormState createState() => ChoiceFormState();
}

class ChoiceFormState extends State<ChoiceForm> {
  TextEditingController textEditingController = TextEditingController();
  String? text;
  @override
  void initState() {
    super.initState();
    text = widget.choice;
    textEditingController.text = widget.choice;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                widget.listener.onTextChange(value, widget.index);
              },
              controller: textEditingController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Choice #${widget.index + 1} ',
                hintText: 'Enter Choice Text',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
