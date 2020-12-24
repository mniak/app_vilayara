import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

import '../model.dart';

class EditEventPage extends StatefulWidget {
  final EventModel _event;
  EditEventPage(this._event);

  @override
  State<StatefulWidget> createState() {
    return _EditEventPageState(_event);
  }
}

class _EditEventPageState extends State<EditEventPage> {
  final EventModel _event;
  _EditEventPageState(this._event);

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _urlController = TextEditingController();

  final _dateFormat = DateFormat("dd/MM/yyyy HH:mm");

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = _event.name;
      _dateController.text = _dateFormat.format(_event.date);
      _urlController.text = _event.url;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future saveEvent() async {
    if (_event.id == null) {
      await FirebaseFirestore.instance.collection("events").add(_event.asMap());
    } else {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(_event.id)
          .set(_event.asMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Editar Evento')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: TextFormField(
                autofocus: true,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Nome do Evento",
                ),
                validator: (txt) => txt == null || txt.length < 1
                    ? "O nome não pode estar vazio"
                    : null,
              ),
              subtitle: Text(
                  "Não precisa colocar a data no nome, pois o site vai adicionar a data automaticamente no final"),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: DateTimeField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: "Data",
                  ),
                  format: _dateFormat,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 2)));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  }),
            ),
            ListTile(
              leading: Icon(Icons.hourglass_bottom),
              title: Text("Sumir exatamente na data"),
              subtitle: Text("Se não, expira 5 horas depois"),
              trailing: Switch(
                value: _event.until,
                onChanged: (v) => setState(() => _event.until = v),
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
                validator: (txt) => !isURL(txt) ? "Não é um link válido" : null,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _event.name = _nameController.text;
            _event.date = _dateFormat.parse(_dateController.text);
            _event.url = _urlController.text;

            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text('Salvando dados')));
            await saveEvent();
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
