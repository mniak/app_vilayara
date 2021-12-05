import 'package:app_comunicacao_vilayara/events/page.dart';
import 'package:app_comunicacao_vilayara/import/page.dart';
import 'package:app_comunicacao_vilayara/login/auth.dart';
import 'package:app_comunicacao_vilayara/login/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicação Vila Yara'),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await signOutGoogle();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  },
                ));
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Gerenciar Eventos'),
            subtitle: Text('Criar, remover ou editar eventos'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => EventsPage())),
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text('Gerenciar Links (Em desenvolvimento)'),
            subtitle: Text('Criar, remover ou editar links fixos'),
            enabled: false,
          ),
          ListTile(
            leading: Icon(Icons.import_export),
            title: Text('Importar Calendário'),
            subtitle: Text('A partir de links para arquivos .ics'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ImportPage())),
          ),
        ],
      ),
    );
  }
}
