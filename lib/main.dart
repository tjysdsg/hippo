import 'package:flutter/material.dart';
import 'package:hippo/index.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:hippo/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App(firstBuild: true));
}

class GlobalStateController extends GetxController {
  var loginToken = ''.obs;
  var username = ''.obs;
  KeyValueStore _cache;

  void init() async {
    _cache = KeyValueStore();
    await _cache.init();
    loginToken = RxString(_cache.get('loginToken', defaultValue: ''));
    username = RxString(_cache.get('username', defaultValue: ''));
  }

  setUserInfo(String username, String token) {
    loginToken = RxString(token);
    this.username = RxString(username);
    _cache.set('loginToken', token);
    _cache.set('username', username);
  }

  clearUserInfo() {
    loginToken = RxString('');
    this.username = RxString('');
    _cache.delete('loginToken');
    _cache.delete('username');
  }
}

class App extends StatelessWidget {
  final GlobalStateController gsc = Get.put(GlobalStateController());

  App({Key key, bool firstBuild = false}) : super(key: key) {
    if (firstBuild) gsc.init();
  }

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
      title: 'CALL',
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
