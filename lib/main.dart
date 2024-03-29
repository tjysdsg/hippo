import 'package:flutter/material.dart';
import 'package:hippo/index.dart';
import 'package:get/get.dart';
import 'package:hippo/constants.dart' as constants;
import 'package:oktoast/oktoast.dart';
import 'package:hippo/database.dart';
import 'package:universal_io/io.dart' show Platform;
import 'platform_check.dart' show PlatformCheck;
import 'package:hippo/appcenter_wrapper.dart'
    if (PlatformCheck.isMobile) 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformCheck.isMobile) {
    await AppCenter.startAsync(
      appSecretAndroid: '2ff93d0d-bf85-4b23-90da-5a1ba8a773ac',
      appSecretIOS: '946b2162-e144-4567-872e-d5cb0cc2a6f1',
      enableDistribute: true,
      usePrivateDistributeTrack: true,
    );
  }

  if (Platform.isAndroid) {
    await AppCenter.configureDistributeDebugAsync(enabled: true);
  }

  runApp(App(firstBuild: true));
}

class GlobalStateController extends GetxController {
  var loginToken = ''.obs;
  var username = ''.obs;
  var onCampus = true.obs;
  KeyValueStore _cache;

  /// the state of current active widget, used for refreshing the page if isOnCampus is updated
  State<StatefulWidget> currentWidgetState;

  setCurrentActiveWidgetState(State<StatefulWidget> state) {
    debugPrint("Current active widget state is $state");
    currentWidgetState = state;
  }

  void init() async {
    debugPrint('============================');
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

  setIsOnCampus(bool val) {
    onCampus = RxBool(val);

    currentWidgetState.setState(() {});
  }

  isOnCampus() {
    return onCampus.value;
  }

  getServerUrl() {
    String ret = constants.ServerInfo.getServerUrl(isOnCampus());
    debugPrint("Using server url: $ret");
    return ret;
  }

  getServerIp() {
    String ret = constants.ServerInfo.getServerIp(isOnCampus());
    debugPrint("Using server IP: $ret");
    return ret;
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue)
            .copyWith(secondary: Colors.redAccent),
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
