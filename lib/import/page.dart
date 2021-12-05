import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Importar Calendário'),
      ),
      body: Form(
          child: Column(
        children: [TextFormField()],
      )),
    );
  }
}
