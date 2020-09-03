import 'package:flutter/material.dart';
import 'package:hippo/index.dart';
import 'package:get/get.dart';

void main() {
  runApp(App());
}

class GlobalStateController extends GetxController {
  var loginToken = ''.obs;

  setLoginToken(String token) {
    loginToken = RxString(token);
  }
}

class App extends StatelessWidget {
  final GlobalStateController gsc = Get.put(GlobalStateController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: Colors.redAccent,
      ),
      home: Index(
        title: 'Practices',
        gsc: gsc,
      ),
    );
  }
}
