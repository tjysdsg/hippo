import 'dart:async';

class AppCenter {
  static Future startAsync({
    String appSecretAndroid,
    String appSecretIOS,
    enableAnalytics = true,
    enableCrashes = true,
    enableDistribute = false,
    usePrivateDistributeTrack = false,
    disableAutomaticCheckForUpdate = false,
  }) async {}

  static Future trackEventAsync(String name,
      [Map<String, String> properties]) async {}

  static Future<bool> isAnalyticsEnabledAsync() async {}

  static Future<String> getInstallIdAsync() async {}

  static Future configureAnalyticsAsync({enabled}) async {}

  static Future<bool> isCrashesEnabledAsync() async {}

  static Future configureCrashesAsync({enabled}) async {}

  static Future<bool> isDistributeEnabledAsync() async {}

  static Future configureDistributeAsync({enabled}) async {}

  static Future configureDistributeDebugAsync({enabled}) async {}

  static Future _disableAutomaticCheckForUpdateAsync() async {}

  static Future checkForUpdateAsync() async {}
}
