import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String name;
  DateTime date;
  String url;
  bool until;
  bool showOnDay;

  Event() {
    date = DateTime.now();
  }
  Event.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    id = doc.id;
    name = data["name"];
    date = DateTime.fromMillisecondsSinceEpoch(
        (data["date"] as Timestamp).millisecondsSinceEpoch);
    url = data["url"];
    until = data["until"] ?? false;
    showOnDay = data["showOnDay"] ?? false;
  }

  Map<String, dynamic> asMap() {
    final map = Map<String, dynamic>();
    map["name"] = name;
    map["date"] =
        Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
    map["url"] = url;
    if (until) map["until"] = true;
    if (showOnDay) map["showOnDay"] = true;
    return map;
  }
}
