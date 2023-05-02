
import '../data/question.dart';
class Section {
  String? title, description, sectionId;
  List<Question>? questions = [];
  String? sectionNumber;

  Section(
      {required this.title,
        required this.sectionNumber,
        this.questions, required this.sectionId,
        required this.description});

  Section.fromJson(Map data) {
    sectionId = data['sectionId'];
    title = data['title'];
    sectionNumber = data['sectionNumber'];
    questions = [];
    if (data['questions'] != null) {
      List  list = data['questions'];
      for (var m in list) {
        questions!.add(Question.fromJson(m));
      }
    }
    description = data['description'];

  }
  Map<String, dynamic> toJson() {
    List mQuestions = [];
    if (questions != null) {
      for (var photo in questions!) {
        mQuestions.add(photo.toJson());
      }
    }

    Map<String, dynamic> map = {
      'title': title,
      'sectionNumber': sectionNumber,
      'description': description,
      'questions': mQuestions,
      'sectionId': sectionId,


    };
    return map;
  }
}
