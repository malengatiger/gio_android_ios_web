
class UserCount {
  String? userId;
  int photos = 0;
  int videos = 0;
  int projects = 0;

  UserCount(
      {required this.userId,
      required this.projects,
      required this.videos,
      required this.photos});

  UserCount.fromJson(Map data) {
    userId = data['userId'];
    videos = data['videos'];
    projects = data['projects'];
    photos = data['photos'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userId': userId,
      'videos': videos,
      'projects': projects,
      'photos': photos,
    };
    return map;
  }
}

class ProjectCount {
  String? projectId;
  int photos = 0, videos = 0;

  ProjectCount(
      {required projectId, required this.videos, required this.photos});

  ProjectCount.fromJson(Map data) {
   projectId = data['projectId'];
   videos = data['videos'];
   photos = data['photos'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'projectId': projectId,
      'videos': videos,
      'photos': photos,
    };
    return map;
  }
}
