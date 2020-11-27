import 'package:app_comunicacao_vilayara/events/edit/page.dart';
import 'package:app_comunicacao_vilayara/events/model.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Iterable<EventModel> _events = [];
  final _dateFormat = DateFormat("dd/MM/yyyy HH:mm");

  void fetchEvents() async {
    final collection = FirebaseFirestore.instance
        .collection("events")
        .where("date", isGreaterThan: DateTime.now().add(Duration(hours: -6)))
        .orderBy("date");
    collection.snapshots().listen((snapshot) {
      final events = snapshot.docs.map((doc) => EventModel.fromDoc(doc));
      setState(() {
        _events = events;
      });
    }).onError((err) {
      setState(() {
        _events = [];
      });
      _scaffold.currentState
          .showSnackBar(SnackBar(content: Text("Error: $err")));
    });
  }

  void fetchLinks() async {
    final doc = await FirebaseFirestore.instance
        .collection("pages")
        .doc("events")
        .get();

    setState(() {
      _pageUrl = doc != null ? Uri.parse(doc.data()["url"]) : null;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchLinks();
  }

  Uri _pageUrl;
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  Future deleteEvent(EventModel event) async {
    await FirebaseFirestore.instance
        .collection("events")
        .doc(event.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Gerenciar Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: _pageUrl != null
                ? () async {
                    final url = _pageUrl.toString();
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                : null,
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _pageUrl != null
                ? () async {
                    await FlutterClipboard.copy(_pageUrl.toString());
                    _scaffold.currentState
                        .showSnackBar(SnackBar(content: Text("Link copiado")));
                  }
                : null,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (_, idx) {
          final event = _events.elementAt(idx);
          final tile = ListTile(
            leading: Icon(Icons.event),
            title: Text(event.name),
            subtitle: Text(_dateFormat.format(event.date)),
            trailing: FlatButton(
              child: Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditEventPage(event)),
              ),
            ),
          );
          return Dismissible(
            key: Key(event.id),
            child: tile,
            onDismissed: (direction) {
              deleteEvent(event);
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Apagar evento"),
                  content:
                      Text("Você quer mesmo remover o evento ${event.name}"),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Apagar")),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                  ],
                ),
              );
            },
            background: Container(color: Colors.red),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EditEventPage(EventModel())),
        ),
      ),
    );
  }
}
