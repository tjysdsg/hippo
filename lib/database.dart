import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class KeyValueStore {
  Box _box;

  Future<void> init() async {
    try {
      String path;
      if (Platform.isAndroid) {
        path = await getStorageDir() + '/database.hive';
        Hive.init(path);
      } else if (Platform.isIOS) {
        path = await getStorageDir() + '/database.hive';
        Hive.init(path);
      } else if (kIsWeb) {
        Hive.initFlutter();
      } else {
        throw Exception("Doesn't support this platform");
      }
      debugPrint('Local cache database initialized at: $path');
      _box = await Hive.openBox('data');
    } catch (e) {
      debugPrint('Failed to initialize hive db: $e');
    }
  }

  void set(String key, dynamic value) {
    _box.put(key, value);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  void delete(String key) {
    _box.delete(key);
  }
}

Future<String> getStorageDir() async {
  if (Platform.isAndroid) {
    return (await getExternalStorageDirectory()).path;
  } else if (Platform.isIOS) {
    return (await getApplicationDocumentsDirectory()).path;
  } else {
    throw Exception("Doesn't support storage on this platform");
  }
}
