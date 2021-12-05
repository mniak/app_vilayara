import 'package:app_comunicacao_vilayara/domain/event.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:rrule/rrule.dart';

class CalendarEvent {
  final Map<String, dynamic> rawData;
  final String name;
  final String description;
  final String location;
  final RecurrenceRule recurrenceRule;
  final DateTime startDate;
  final DateTime endDate;

  bool showUntilDate = false;
  bool showOnDay = false;

  CalendarEvent(this.rawData)
      : this.name = rawData["summary"],
        this.description = rawData["description"],
        this.location = rawData["location"],
        this.recurrenceRule = parseRRule(rawData["rrule"]),
        this.startDate =
            (rawData["dtstart"] as IcsDateTime).toDateTime().toUtc(),
        this.endDate = (rawData["dtend"] as IcsDateTime).toDateTime().toUtc();

  String toString() => this.rawData.toString();

  static RecurrenceRule parseRRule(String rrule) {
    rrule = rrule.replaceAll(RegExp("WKST=\\w{2};"), "");
    return RecurrenceRule.fromString('RRULE:' + rrule);
  }

  List<DateTime> occurrences() {
    if (recurrenceRule == null) {
      return [
        startDate,
      ];
    }
    return recurrenceRule
        .getInstances(start: startDate)
        // to local
        .map((x) => DateTime.fromMillisecondsSinceEpoch(
            startDate.millisecondsSinceEpoch))
        .toList();
  }
}
