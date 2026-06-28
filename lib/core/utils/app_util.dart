import 'package:flutter/foundation.dart';

class AppUtil {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static void printLog(String message) {
    log(message);
  }
}
