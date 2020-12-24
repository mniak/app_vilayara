import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String name;
  DateTime date;
  String url;
  bool until;

  EventModel() {
    date = DateTime.now();
  }
  EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data();
    id = doc.id;
    name = data["name"];
    date = DateTime.fromMillisecondsSinceEpoch(
        (data["date"] as Timestamp).millisecondsSinceEpoch);
    url = data["url"];
    until = data["until"] ?? false;
  }

  Map<String, dynamic> asMap() {
    final map = Map<String, dynamic>();
    map["name"] = name;
    map["date"] =
        Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
    map["url"] = url;
    if (until) map["until"] = true;
    return map;
  }
}
