import 'package:flutter/material.dart';
import 'package:hippo/index.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: Colors.redAccent,
      ),
      home: Index(title: 'Practices'),
    );
  }
}
