import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class KeyValueStore {
  Box _box;

  Future<void> init() async {
    String path;
    if (!kIsWeb) {
      path = (await getExternalStorageDirectory()).path + '/database.hive';
    }
    Hive.initFlutter(path);

    try {
      _box = await Hive.openBox('data');
    } catch (e) {
      debugPrint('Failed to initialize hive db: $e');
    }
    debugPrint('Local cache database initialized at: $path');
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
