import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const int _port = 3000;

  static String get _host {
    if (kIsWeb) {
      return 'http://127.0.0.1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2';
    }
    return 'http://127.0.0.1';
  }

  static String get baseUrl => '$_host:$_port/api';
}
