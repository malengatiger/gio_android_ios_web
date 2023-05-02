


/*
private String stringToTranslate;
    private String source;
    private String target;
    private String format;
    private String translatedText;
 */

class TranslationBag {
  String? source, target, translatedText;

  TranslationBag(
      {required this.source,
      required this.target,
      required this.translatedText,});

  TranslationBag.fromJson(Map data) {
    source = data['source'];
    target = data['target'];
    translatedText = data['translatedText'];
  }
  Map<String, dynamic> toJson() {

    Map<String, dynamic> map = {
      'source': source,
      'target': target,
      'translatedText': translatedText,

    };
    return map;
  }
}
