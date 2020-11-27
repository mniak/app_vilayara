import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String name;
  DateTime date;
  String url;

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
  }

  Map<String, dynamic> asMap() {
    final map = Map<String, dynamic>();
    map["name"] = name;
    map["date"] =
        Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
    map["url"] = url;
    return map;
  }
}
