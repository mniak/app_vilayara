import 'dart:developer';
import 'dart:html';
import 'dart:io';
import 'package:app_comunicacao_vilayara/domain/event.dart';
import 'package:app_comunicacao_vilayara/import/calendar_event.dart';
import 'package:app_comunicacao_vilayara/widgets/loadable_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

class ImportPage extends StatefulWidget {
  final String link;
  ImportPage(this.link) {}

  @override
  State<StatefulWidget> createState() => _ImportPageState(link);
}

class _ImportPageState extends State<ImportPage> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  final _form = GlobalKey<FormState>();
  final _dateFormat = DateFormat("dd/MM/yyyy HH:mm");
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  final String link;
  _ImportPageState(this.link) {}

  CalendarEvent event;
  bool ready = false;

  static Future<CalendarEvent> fetchEvent(String link) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(link));
    } catch (e) {
      // Try using CORS proxy if request failed
      final uri = Uri.parse("https://vilayara7.org/api/cors_proxy")
          .replace(queryParameters: {'u': link});
      response = await http.get(Uri.parse(uri.toString()));
    }
    if (response == null || response.statusCode != 200) {
      throw Exception('O link não pôde ser carregado');
    }

    final ical = ICalendar.fromString(response.body);
    final vevent = ical.data
        .where((e) => e.containsKey("type") && e["type"] == "VEVENT")
        .first;
    return CalendarEvent(vevent);
  }

  List<Event> getDbEvents(CalendarEvent event) {
    return event.occurrences().map((date) {
      final dbEvent = Event();
      dbEvent.name = _nameController.text;
      dbEvent.date = date;
      dbEvent.url = _urlController.text;
      dbEvent.until = event.showUntilDate;
      dbEvent.showOnDay = event.showOnDay;
      return dbEvent;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchEvent(link).then((event) => setState(() {
          this.ready = true;
          this.event = event;
          this._nameController.text = event.name;
          this._urlController.text = event.location;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Importar Calendário'),
      ),
      body: LoadableContent(
        loaded: () => this.ready,
        child: Form(
          key: _form,
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.description),
                title: TextFormField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Nome do Evento"),
                  validator: (txt) => (txt ?? "").isEmpty
                      ? "O nome não pode estar vazio"
                      : null,
                ),
                subtitle: Text(
                    "Não precisa colocar a data no nome, pois o site vai adicionar a data automaticamente no final"),
              ),
              ListTile(
                leading: Icon(Icons.hourglass_bottom),
                title: Text("Sumir exatamente no horário"),
                subtitle: Text("Se não, expira 5 horas depois"),
                trailing: Switch(
                  value: event?.showUntilDate,
                  onChanged: (v) => setState(() => event.showUntilDate = v),
                ),
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny),
                title: Text("Aparecer só no dia"),
                subtitle:
                    Text("Ou seja, aparece à meia-noite do dia do evento"),
                trailing: Switch(
                  value: event?.showOnDay,
                  onChanged: (v) => setState(() => event?.showOnDay = v),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: TextFormField(
                  minLines: 1,
                  maxLines: 8,
                  keyboardType: TextInputType.url,
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: "Link",
                  ),
                  validator: (txt) =>
                      !isURL(txt) ? "Não é um link válido" : null,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text("Ocorrências"),
                subtitle: Builder(
                  builder: (context) {
                    final occurrences = event?.occurrences();
                    if (occurrences == null || occurrences.length == 0)
                      return Text("Nenhuma data");
                    final text = occurrences
                        .map((x) => _dateFormat.format(x))
                        .join("\n");
                    return Text(text);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          if (!_form.currentState.validate()) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Salvando dados')));
          final dbEvents = getDbEvents(event);
          await saveEvents(dbEvents);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

Future<void> saveEvents(List<Event> events) async {
  final eventsCollection = FirebaseFirestore.instance.collection("events");
  final batch = FirebaseFirestore.instance.batch();

  events.forEach((event) {
    final doc = event.asMap();
    doc["test"] = true;
    batch.set(eventsCollection.doc(), doc);
  });
  await batch.commit();
}
