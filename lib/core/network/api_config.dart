import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const int _port = 8080;
  static const String _lanHost = 'http://192.168.1.24';

  static String get _host {
    if (kIsWeb) {
      return 'http://127.0.0.1';
    }
    if (Platform.isAndroid) {
      return _lanHost;
    }
    return _lanHost;
  }

  static String get baseUrl => '$_host:$_port/api';
}
