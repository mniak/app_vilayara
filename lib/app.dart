import 'package:app_comunicacao_vilayara/home/page.dart';
import 'package:app_comunicacao_vilayara/login/page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  bool get _isAuthenticated => FirebaseAuth.instance.currentUser != null;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _isAuthenticated ? HomePage() : LoginPage(),
    );
  }
}
