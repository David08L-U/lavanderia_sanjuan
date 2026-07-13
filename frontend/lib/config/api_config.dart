import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5162/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5162/api';
    }
    return 'http://localhost:5162/api';
  }
}