
import 'package:geo_monitor/library/data/user.dart';

class GioSubscription {
  String? subscriptionId, date;
  User? user;
  String? organizationId;
  String? organizationName, updated;
  int? intDate, intUpdated, subscriptionType, active;

  GioSubscription({
      required this.subscriptionId,
      required this.date,
      required this.user,
      required this.organizationId,
      required this.organizationName,
      this.updated,
      required this.intDate,
      this.intUpdated,
      required this.subscriptionType,
      required this.active});

  GioSubscription.fromJson(Map<String, dynamic> json) {

        subscriptionId = json['subscriptionId'] as String?;
        date = json['date'] as String?;
        user = json['user'] == null
            ? null:
              User.fromJson(json['user'] as Map<String, dynamic>);
        organizationId = json['organizationId'] as String?;
        organizationName = json['organizationName'] as String?;
        updated = json['updated'] as String?;
        intDate = json['intDate'] as int?;
        intUpdated = json['intUpdated'] as int?;
        subscriptionType = json['subscriptionType'] as int?;
        active = json['active'] as int?;

  }
  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'subscriptionId': subscriptionId,
        'date': date,
        'user': user == null? null: user!.toJson(),
        'organizationId': organizationId,
        'organizationName': organizationName,
        'updated': updated,
        'intDate': intDate,
        'intUpdated': intUpdated,
        'subscriptionType': subscriptionType,
        'active': active,
      };

}
