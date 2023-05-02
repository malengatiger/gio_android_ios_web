import '../data/section.dart';

class QuestionnaireResponse {
  String? questionnaireId, userId, respondentId, questionnaireResponseId;
  List<Section>? sections;

  QuestionnaireResponse({required this.questionnaireId, required this.userId,
    required this.respondentId,
    required this.questionnaireResponseId, required this.sections});

  QuestionnaireResponse.fromJson(Map data) {
    userId = data['userId'];
    questionnaireResponseId = data['questionnaireResponseId'];
    sections = data['sections'];
    respondentId = data['respondentId'];
    questionnaireId = data['questionnaireId'];
  }
  Map<String, dynamic> toJson() {
    List mSecs = [];
    if (sections != null) {
      for (var s in sections!) {
        mSecs.add(s.toJson());
      }
    }

    Map<String, dynamic> map = {
      'userId': userId,
      'questionnaireResponseId': questionnaireResponseId,
      'sections': mSecs,
      'respondentId': respondentId,
      'questionnaireId': questionnaireId,
    };
    return map;
  }
}
