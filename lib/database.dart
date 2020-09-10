import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class KeyValueStore {
  Box _box;

  Future<void> init() async {
    String path = (await getExternalStorageDirectory()).path + '/database.hive';
    Hive.init(path);
    _box = await Hive.openBox('data');
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
