import 'package:flutter/material.dart';
import 'package:hippo/index.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(App());
}

class GlobalStateController extends GetxController {
  var loginToken = ''.obs;
  var username = ''.obs;

  setUserInfo(String username, String token) {
    loginToken = RxString(token);
    this.username = RxString(username);
  }
}

class App extends StatelessWidget {
  final GlobalStateController gsc = Get.put(GlobalStateController());

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
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

    return OKToast(
      child: app,
      textPadding: EdgeInsets.all(10),
      radius: 5,
      dismissOtherOnShow: true,
    );
  }
}
