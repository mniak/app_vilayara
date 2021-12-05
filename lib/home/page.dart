import 'package:app_comunicacao_vilayara/events/page.dart';
import 'package:app_comunicacao_vilayara/import/page.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:app_comunicacao_vilayara/login/auth.dart';
import 'package:app_comunicacao_vilayara/login/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

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
            onTap: () async {
              final link = await prompt(
                context,
                title: Text('Qual o link do calendário?'),
                hintText: 'Tipicamente um .ics',
                validator: (txt) => !isURL(txt) ? "Não é um link válido" : null,
                initialValue:
                    "https://adventistas.zoom.us/meeting/tZcsfu6tqzwvHNWZmXfHHffE3gBD2GOwPaYn/ics?icsToken=98tyKuGrrzItH9GStR-GRpwqBYr4KO_wmGZYgo1qphLdBQh7ZAXTZeVgFuBYP8_g",
                maxLines: 5,
                autoFocus: true,
                barrierDismissible: true,
                textCapitalization: TextCapitalization.words,
              );
              if (link == null) return null;
              return Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ImportPage(link)));
            },
          ),
        ],
      ),
    );
  }
}
