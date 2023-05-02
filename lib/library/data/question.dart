
import 'answer.dart';

class Question {
  String? text, created;
  List<Answer>? answers;
  String? questionType;
  List<String>? choices;

  Question(
      {required this.text,
      this.answers,
      required this.questionType,
      this.choices});

  Question.fromJson(Map data) {
    text = data['text'];
    created = data['created'];
    choices = [];
    if (data['choices'] != null) {
      List  list = data['choices'];
      for (var m in list) {
        choices!.add(m);
      }
    }
      questionType = data['questionType'];


    answers = [];
    if (data['answers'] != null) {
      List  list = data['answers'];
      for (var m in list) {
        answers!.add(Answer.fromJson(m));
      }
    }

  }
  Map<String, dynamic> toJson() {
    List mAnswers = [];
    if (answers != null) {
      for (var a in answers!) {
        mAnswers.add(a.toJson());
      }
    }
    Map<String, dynamic> map = {
      'text': text,
      'answers': mAnswers,
      'questionType': questionType,
      'choices': choices,
      'created': created,
    };
    return map;
  }
}
