import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart' show Platform;

class PlatformCheck {
  static final bool isMobile = (Platform.isAndroid || Platform.isIOS);
  static final bool isWeb = kIsWeb;
}
