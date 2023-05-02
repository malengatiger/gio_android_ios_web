
import 'photo.dart';

class UploadBag {
  Photo? photo;
  dynamic thumbnailBytes;
  dynamic fileBytes;
  UploadBag(
      {required this.photo,
        required this.fileBytes,
        required this.thumbnailBytes});

  UploadBag.fromJson(Map data) {
    photo = data['photo'];
    thumbnailBytes = data['thumbnailBytes'];
    fileBytes = data['fileBytes'];
    if (data['photo'] != null) {
      photo = Photo.fromJson(data['photo']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'photo': photo == null? null: photo!.toJson(),
      'thumbnailBytes': thumbnailBytes,
      'fileBytes': fileBytes,
    };
    return map;
  }
}
