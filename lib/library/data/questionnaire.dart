import '../data/section.dart';

class Questionnaire {
  late String questionnaireId,
      title,
      name,
      organizationId,
      description,
      organizationName,
      created,
      countryName;
  String? countryId;
  late List<Section> sections = [];

  Questionnaire(
      {required this.title,
      required this.name,
      required this.organizationId,
      required this.description,
      required this.organizationName,
       this.countryId,
      required this.created,
      required this.countryName,
       required this.sections});

  Questionnaire.fromJson(Map data) {
    title = data['title'];
    organizationId = data['organizationId'];
    sections = [];
    if (data['sections'] != null) {
      List list = data['sections'];
      for (var m in list) {
        sections.add(Section.fromJson(m));
      }
    }
    description = data['description'];
    organizationName = data['organizationName'];
    countryId = data['countryId'];
    created = data['created'];
    countryName = data['countryName'];
  }
  Map<String, dynamic> toJson() {
    List mSecs = [];
    for (var s in sections) {
      mSecs.add(s.toJson());
    }

    Map<String, dynamic> map = {
      'title': title,
      'organizationId': organizationId,
      'description': description,
      'sections': mSecs,
      'organizationName': organizationName,
      'created': created,
      'countryName': countryName,
      'countryId': countryId,
    };
    return map;
  }
}
