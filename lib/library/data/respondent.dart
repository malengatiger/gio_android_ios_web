
class Respondent {
  String? firstName, lastName, userId, email, cellphone, gender;

  Respondent({required this.firstName, required this.lastName,  this.email, this.cellphone,
    required this.gender,  });

  Respondent.fromJson(Map data) {
    firstName = data['firstName'];
    lastName = data['lastName'];
    userId = data['userId'];
    email = data['email'];
    cellphone = data['cellphone'];
    gender = data['gender'];
  }
  Map<String, dynamic> toJson() {

    Map<String, dynamic> map = {
      'firstName': firstName,
      'lastName': lastName,
      'userId': userId,
      'email': email,
      'cellphone': cellphone,
      'gender': gender,
    };
    return map;
  }

}